import 'dotenv/config';
import { readFileSync } from 'node:fs';

import express from 'express';
import admin from 'firebase-admin';
import { PayOS } from '@payos/node';

// ─────────────────────────────────────────────────────────────
// Firebase Admin — để webhook cập nhật paymentStatus của đơn.
// Cần file service account JSON tải từ Firebase Console
// (Project settings → Service accounts → Generate new private key).
// ─────────────────────────────────────────────────────────────
const serviceAccount = JSON.parse(
  readFileSync(process.env.FIREBASE_SERVICE_ACCOUNT_PATH, 'utf8'),
);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────
// PayOS — 3 khóa để trong .env, KHÔNG hardcode, KHÔNG lên app Flutter.
// ─────────────────────────────────────────────────────────────
const payos = new PayOS({
  clientId: process.env.PAYOS_CLIENT_ID,
  apiKey: process.env.PAYOS_API_KEY,
  checksumKey: process.env.PAYOS_CHECKSUM_KEY,
});

// URL PayOS redirect WebView về sau khi trả xong / hủy.
// Chỉ để đóng WebView — "đã trả tiền" xác nhận qua webhook, không qua redirect.
const RETURN_URL = process.env.RETURN_URL || 'https://example.com/pay/success';
const CANCEL_URL = process.env.CANCEL_URL || 'https://example.com/pay/cancel';

const app = express();
app.use(express.json());

// ─── Tạo link thanh toán cho 1 đơn đã có trên Firestore (paymentStatus=pending)
// Body: { orderId: string, amount: number, description?: string }
// Trả:  { checkoutUrl, qrCode, payosOrderCode }
app.post('/create-payment', async (req, res) => {
  try {
    const { orderId, amount, description } = req.body ?? {};
    if (!orderId || !amount || amount <= 0) {
      return res.status(400).json({ error: 'Thiếu orderId hoặc amount không hợp lệ' });
    }

    // orderCode PayOS PHẢI là số nguyên dương, duy nhất mỗi lần. Dùng timestamp.
    const payosOrderCode = Date.now();
    // PayOS giới hạn description tối đa 25 ký tự.
    const desc = String(description || `DH ${orderId}`).slice(0, 25);

    const link = await payos.paymentRequests.create({
      orderCode: payosOrderCode,
      amount: Math.round(amount), // VND phải là số nguyên
      description: desc,
      returnUrl: RETURN_URL,
      cancelUrl: CANCEL_URL,
    });

    // Lưu payosOrderCode lên đơn để webhook tìm ngược lại được.
    await db.collection('orders').doc(orderId).update({
      payosOrderCode,
      paymentLinkId: link.paymentLinkId ?? null,
    });

    return res.json({
      checkoutUrl: link.checkoutUrl,
      qrCode: link.qrCode,
      payosOrderCode,
    });
  } catch (e) {
    console.error('[create-payment]', e);
    return res.status(500).json({ error: 'Không tạo được link thanh toán' });
  }
});

// ─── Webhook PayOS gọi khi có biến động thanh toán.
// PayOS gửi { code, desc, success, data, signature }. verify() là ASYNC, nhận
// nguyên body, trả về `data` đã xác thực chữ ký (hoặc ném lỗi nếu giả mạo).
app.post('/payos-webhook', async (req, res) => {
  // Log raw để soi đúng shape PayOS gửi (phân biệt ping xác nhận vs webhook thật).
  console.log('[webhook] raw:', JSON.stringify(req.body));

  // Ping "Kiểm tra webhook" từ dashboard gửi body rỗng / data=null → verify sẽ
  // ném "Invalid webhook data". Đây là bình thường, bỏ qua êm và trả 200.
  if (!req.body || req.body.data == null) {
    console.log('[webhook] ping xác nhận (không có data) → bỏ qua, trả 200');
    return res.status(200).json({ success: true });
  }

  try {
    // verify() ném lỗi nếu chữ ký sai → không tin request giả.
    const data = await payos.webhooks.verify(req.body);
    const orderCode = data?.orderCode;
    console.log(
      `[webhook] verified OK — orderCode=${orderCode} code=${data?.code} ref=${data?.reference}`,
    );

    // verify() thành công = giao dịch thật & thành công (PayOS chỉ webhook khi
    // trả tiền xong). Tìm đơn theo payosOrderCode đã lưu lúc create-payment.
    if (orderCode != null) {
      const snap = await db
        .collection('orders')
        .where('payosOrderCode', '==', orderCode)
        .limit(1)
        .get();

      if (!snap.empty) {
        const doc = snap.docs[0];
        // Idempotent: chỉ cập nhật khi đang pending (webhook có thể gọi lại).
        if (doc.data().paymentStatus === 'pending') {
          await doc.ref.update({
            paymentStatus: 'paid',
            paymentRef: data.reference ?? null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`[webhook] order ${doc.id} → paid (ref ${data.reference})`);
        } else {
          console.log(
            `[webhook] order ${doc.id} đã '${doc.data().paymentStatus}', bỏ qua (idempotent)`,
          );
        }
      } else {
        console.warn(
          `[webhook] KHÔNG tìm thấy đơn nào có payosOrderCode == ${orderCode}`,
        );
      }
    }

    // Luôn trả 200 để PayOS không gọi lại.
    return res.status(200).json({ success: true });
  } catch (e) {
    console.error(
      '[webhook] verify/xử lý lỗi:',
      e.message,
      '| data nhận được:',
      JSON.stringify(req.body?.data),
    );
    // Trả 200 để tránh PayOS retry dồn dập khi chỉ là request rác.
    return res.status(200).json({ success: false });
  }
});

app.get('/health', (_req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`💳 Payment server chạy trên cổng :${PORT}`));
