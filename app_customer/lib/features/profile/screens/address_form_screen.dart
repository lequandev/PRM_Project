import 'dart:async';

import 'package:coffee_shop_core/coffee_shop_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../data/profile_repository.dart';
import '../../../data/session.dart';
import '../providers/address_provider.dart';
import '../services/geo_service.dart';

/// AddressFormScreen — UC-05: thêm mới ([initial] == null) hoặc sửa địa chỉ.
///
/// Hỗ trợ 3 cách nhập nhanh:
/// 1. Gõ ô "Số nhà, tên đường" → gợi ý địa chỉ (Photon/OSM) để chọn
/// 2. Nút "Vị trí hiện tại" → GPS + reverse geocode tự điền form
/// 3. Chạm lên bản đồ để ghim vị trí → tự điền form
class AddressFormScreen extends StatelessWidget {
  const AddressFormScreen({super.key, this.initial});

  final AddressModel? initial;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddressProvider(
        context.read<ProfileRepository>(),
        context.read<CurrentSession>(),
      ),
      child: _AddressFormView(initial: initial),
    );
  }
}

class _AddressFormView extends StatefulWidget {
  const _AddressFormView({this.initial});

  final AddressModel? initial;

  @override
  State<_AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<_AddressFormView> {
  static const _labelSuggestions = ['Nhà', 'Cơ quan', 'Khác'];

  /// Tâm mặc định khi chưa có ghim: Cầu Rồng, Đà Nẵng.
  static const _fallbackCenter = LatLng(16.0611, 108.2275);

  final _formKey = GlobalKey<FormState>();
  final _geo = GeoService();
  final _mapController = MapController();

  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _wardController;
  late final TextEditingController _districtController;
  late final TextEditingController _cityController;
  late bool _isDefault;

  LatLng? _picked;
  Timer? _debounce;
  List<GeoPlace> _placeSuggestions = const [];
  bool _isSearching = false;
  bool _isLocating = false;
  bool _isReversing = false;
  bool _suppressNextSearch = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _labelController = TextEditingController(text: a?.label ?? '');
    _streetController = TextEditingController(text: a?.street ?? '');
    _wardController = TextEditingController(text: a?.ward ?? '');
    _districtController = TextEditingController(text: a?.district ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _isDefault = a?.isDefault ?? false;
    if (a?.lat != null && a?.lng != null) {
      _picked = LatLng(a!.lat!, a.lng!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _labelController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ─── Autocomplete (Photon) ────────────────────────────────

  void _onStreetChanged(String value) {
    if (_suppressNextSearch) {
      _suppressNextSearch = false;
      return;
    }
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() => _placeSuggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() => _isSearching = true);
      try {
        // Thêm city đang nhập (nếu có) cho kết quả sát hơn
        final cityHint = _cityController.text.trim();
        final results = await _geo.search(
          cityHint.isEmpty ? query : '$query, $cityHint',
          nearLat: _picked?.latitude,
          nearLng: _picked?.longitude,
        );
        if (mounted) setState(() => _placeSuggestions = results);
      } catch (_) {
        if (mounted) setState(() => _placeSuggestions = const []);
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _applyPlace(GeoPlace place, {bool fillStreet = true}) {
    _suppressNextSearch = true;
    setState(() {
      if (fillStreet && place.street.isNotEmpty) {
        _streetController.text = place.street;
      }
      if (place.ward.isNotEmpty) _wardController.text = place.ward;
      if (place.district.isNotEmpty) _districtController.text = place.district;
      if (place.city.isNotEmpty) _cityController.text = place.city;
      _picked = LatLng(place.lat, place.lng);
      _placeSuggestions = const [];
    });
    _mapController.move(_picked!, 16);
    FocusScope.of(context).unfocus();
  }

  // ─── GPS (geolocator) ─────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _snack('Hãy bật Vị trí (GPS) trong cài đặt máy.', error: true);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _snack('Bạn đã từ chối quyền vị trí.', error: true);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Quyền vị trí bị chặn — mở Cài đặt ứng dụng để cấp lại.',
            error: true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 12));
      await _pinAndFill(LatLng(pos.latitude, pos.longitude));
    } on TimeoutException {
      _snack('Không lấy được GPS (thử ra chỗ thoáng hơn?).', error: true);
    } catch (_) {
      _snack('Không lấy được vị trí hiện tại.', error: true);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ─── Chạm bản đồ / ghim + reverse geocode ─────────────────

  Future<void> _pinAndFill(LatLng point) async {
    setState(() {
      _picked = point;
      _isReversing = true;
    });
    _mapController.move(point, 16);
    try {
      final place = await _geo.reverse(point.latitude, point.longitude);
      if (place != null && mounted) {
        // Không ghi đè ô đường nếu người dùng đã tự gõ số nhà chi tiết hơn
        final streetEmpty = _streetController.text.trim().isEmpty;
        _applyPlace(place, fillStreet: streetEmpty || place.street.isNotEmpty);
        // Quận/Huyện không tính là thiếu — sau sáp nhập nhiều nơi không còn.
        final missing = _wardController.text.trim().isEmpty ||
            _cityController.text.trim().isEmpty;
        if (missing) {
          _snack('Bản đồ thiếu vài thông tin — điền giúp mấy ô trống nhé.');
        }
      }
    } catch (_) {
      _snack('Đã ghim vị trí — không tự điền được địa chỉ, nhập giúp nhé.');
    } finally {
      if (mounted) setState(() => _isReversing = false);
    }
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? AppColors.error : AppColors.brownAccent,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  // ─── Chip tên gợi nhớ ─────────────────────────────────────

  bool _isChipSelected(String suggestion) {
    final label = _labelController.text.trim();
    if (suggestion == 'Khác') {
      return label.isNotEmpty && !_labelSuggestions.contains(label);
    }
    return label == suggestion;
  }

  void _onChipTap(String suggestion) {
    setState(() {
      _labelController.text = suggestion == 'Khác' ? '' : suggestion;
    });
  }

  // ─── Lưu ──────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<AddressProvider>();

    final address = AddressModel(
      // Giữ nguyên id khi sửa; id '' khi tạo — repo tự sinh.
      id: widget.initial?.id ?? '',
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      isDefault: _isDefault,
      lat: _picked?.latitude ?? widget.initial?.lat,
      lng: _picked?.longitude ?? widget.initial?.lng,
    );

    final ok = _isEditing
        ? await provider.updateAddress(address)
        : await provider.addAddress(address);
    if (!mounted) return;

    if (ok) {
      // Root ScaffoldMessenger nên SnackBar vẫn hiển thị sau khi pop.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content:
              Text(_isEditing ? 'Đã cập nhật địa chỉ' : 'Đã thêm địa chỉ mới'),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(provider.error ?? 'Lưu địa chỉ thất bại.'),
        ),
      );
    }
  }

  // ─── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AddressProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa địa chỉ' : 'Thêm địa chỉ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Tên gợi nhớ',
              style: AppTypography.label
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final suggestion in _labelSuggestions)
                  ChoiceChip(
                    label: Text(suggestion),
                    selected: _isChipSelected(suggestion),
                    selectedColor: AppColors.goldPrimary,
                    labelStyle: AppTypography.buttonSmall.copyWith(
                      color: _isChipSelected(suggestion)
                          ? AppColors.textOnGold
                          : AppColors.textSecondary,
                    ),
                    onSelected: (_) => _onChipTap(suggestion),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _labelController,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Tên gợi nhớ'),
              decoration: const InputDecoration(
                hintText: 'VD: Nhà, Trường, Nhà bạn thân…',
                prefixIcon: Icon(Icons.bookmark_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Nút định vị nhanh ──
            OutlinedButton.icon(
              onPressed: _isLocating ? null : _useCurrentLocation,
              icon: _isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                  _isLocating ? 'Đang định vị…' : 'Dùng vị trí hiện tại'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.goldPrimary),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Ô đường + autocomplete ──
            TextFormField(
              controller: _streetController,
              textInputAction: TextInputAction.next,
              onChanged: _onStreetChanged,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Số nhà, tên đường'),
              decoration: InputDecoration(
                labelText: 'Số nhà, tên đường',
                hintText: 'Gõ để tìm — VD: 123 Nguyễn Văn Linh',
                prefixIcon: const Icon(Icons.signpost_outlined),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (_placeSuggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadow.md,
                ),
                child: Material(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final place in _placeSuggestions)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined,
                              color: AppColors.goldPrimary),
                          title: Text(
                            place.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium,
                          ),
                          onTap: () => _applyPlace(place),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _wardController,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Phường/Xã'),
              decoration: const InputDecoration(
                labelText: 'Phường/Xã',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _districtController,
              textInputAction: TextInputAction.next,
              // Sáp nhập 2025 bỏ cấp quận/huyện → không bắt buộc nữa.
              decoration: const InputDecoration(
                labelText: 'Quận/Huyện (nếu có)',
                helperText: 'Khu vực đã sáp nhập thì bỏ trống',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cityController,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  FormValidators.required(v, fieldName: 'Tỉnh/Thành phố'),
              decoration: const InputDecoration(
                labelText: 'Tỉnh/Thành phố',
                prefixIcon: Icon(Icons.public_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Bản đồ: ghim cố định giữa khung, kéo map rồi bấm xác nhận ──
            Row(
              children: [
                Text(
                  'Ghim trên bản đồ',
                  style: AppTypography.label
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '(kéo bản đồ, ghim luôn ở giữa)',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _picked ?? _fallbackCenter,
                        initialZoom: _picked != null ? 16 : 13,
                        // Chạm = đưa điểm đó về giữa khung; thông tin chỉ
                        // được điền khi bấm "Chọn vị trí này".
                        onTap: (_, point) => _mapController.move(
                          point,
                          _mapController.camera.zoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.company.PRM',
                        ),
                        const SimpleAttributionWidget(
                          source: Text('© OpenStreetMap'),
                        ),
                      ],
                    ),
                    // Ghim đỏ cố định — padding bottom = chiều cao icon để
                    // MŨI ghim (đáy icon) trỏ đúng tâm bản đồ.
                    const IgnorePointer(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 44),
                          child: Icon(
                            Icons.location_pin,
                            size: 44,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _isReversing
                  ? null
                  : () => _pinAndFill(_mapController.camera.center),
              icon: _isReversing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.where_to_vote_outlined),
              label: Text(
                  _isReversing ? 'Đang lấy địa chỉ…' : 'Chọn vị trí này'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brownAccent,
                side: const BorderSide(color: AppColors.goldPrimary),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            if (_picked != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Đã chọn: ${_picked!.latitude.toStringAsFixed(5)}, '
                '${_picked!.longitude.toStringAsFixed(5)}',
                textAlign: TextAlign.center,
                style:
                    AppTypography.caption.copyWith(color: AppColors.textHint),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Material(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                value: _isDefault,
                activeThumbColor: AppColors.goldPrimary,
                title: const Text('Đặt làm mặc định',
                    style: AppTypography.bodyLarge),
                subtitle: Text(
                  'Tự động chọn địa chỉ này khi giao hàng',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textHint),
                ),
                onChanged: (value) => setState(() => _isDefault = value),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.textOnGold,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            onPressed: isSaving ? null : _save,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Lưu thay đổi' : 'Lưu địa chỉ',
                    style: AppTypography.button),
          ),
        ),
      ),
    );
  }
}
