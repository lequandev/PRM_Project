# Coffee Shop — Payment Server (PayOS)

Server nhỏ chạy trên máy Linux ở nhà (sau nginx). Nhiệm vụ:

1. `POST /create-payment` — app Flutter gọi để tạo link thanh toán PayOS cho một đơn.
2. `POST /payos-webhook` — PayOS gọi khi khách trả tiền xong → verify chữ ký → cập nhật `paymentStatus = 'paid'` cho đơn trên Firestore.
3. `GET /health` — kiểm tra sống.

App Flutter **không** gọi PayOS trực tiếp (secret key phải ở server). App chỉ gọi server này rồi **nghe đơn của mình** trên Firestore để biết đã trả tiền.

## 1. Cài đặt

```bash
cd payment_server
npm install
cp .env.example .env      # rồi điền giá trị thật vào .env
```

- Điền 3 khóa PayOS vào `.env` (Client ID / API Key / Checksum Key).
- Tải **service account JSON** của Firebase: Console → ⚙️ Project settings → Service accounts → *Generate new private key* → lưu thành `payment_server/serviceAccountKey.json` (đã gitignore).

## 2. Chạy

```bash
npm start          # hoặc: node --watch index.js khi dev
```

Chạy nền lâu dài bằng systemd (khuyến nghị) — tạo `/etc/systemd/system/coffee-pay.service`:

```ini
[Unit]
Description=Coffee Shop Payment Server
After=network.target

[Service]
WorkingDirectory=/path/to/payment_server
ExecStart=/usr/bin/node index.js
Restart=always
User=youruser
EnvironmentFile=/path/to/payment_server/.env

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now coffee-pay
```

## 3. nginx (subdomain → cổng local)

```nginx
server {
    server_name pay.your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    # (certbot tự thêm block listen 443 + ssl_certificate ở đây)
}
```

```bash
sudo certbot --nginx -d pay.your-domain.com   # HTTPS — PayOS webhook BẮT BUỘC https
```

## 4. Đăng ký webhook trên dashboard PayOS

Vào dashboard PayOS → mục Webhook → dán URL:

```
https://pay.your-domain.com/payos-webhook
```

Bấm "Kiểm tra" — server phải trả 200 (endpoint đã xử lý sẵn).

## 5. Kiểm tra nhanh

```bash
curl https://pay.your-domain.com/health          # {"ok":true}
curl -X POST https://pay.your-domain.com/create-payment \
  -H 'Content-Type: application/json' \
  -d '{"orderId":"<id-đơn-thật-trên-firestore>","amount":50000,"description":"test"}'
# → trả về checkoutUrl, mở bằng browser để test luồng trả tiền
```

## Ghi chú bảo mật

- `.env` + `serviceAccountKey.json` **không bao giờ commit** (đã gitignore).
- Checksum Key rò rỉ = người khác giả được webhook "đã thanh toán". Giữ kín.
- Webhook là **nguồn sự thật duy nhất** — không tin redirect returnUrl.
- Đơn phải tồn tại (paymentStatus=pending) TRƯỚC khi tạo payment; webhook tìm đơn qua field `payosOrderCode`.
