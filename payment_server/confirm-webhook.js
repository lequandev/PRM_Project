// confirm-webhook.js — chạy 1 lần để ĐĂNG KÝ URL webhook cho kênh PayOS này.
//
// Dùng chính 3 khóa trong .env. PayOS sẽ gọi thử URL để xác nhận nó phản hồi
// 200; endpoint /payos-webhook của mình đã trả 200 cho ping rỗng nên sẽ pass.
//
//   node confirm-webhook.js
//
// Sau khi chạy OK, mọi giao dịch trả tiền của kênh này sẽ bắn webhook về URL.
import 'dotenv/config';
import { PayOS } from '@payos/node';

const payos = new PayOS({
  clientId: process.env.PAYOS_CLIENT_ID,
  apiKey: process.env.PAYOS_API_KEY,
  checksumKey: process.env.PAYOS_CHECKSUM_KEY,
});

const url = process.env.WEBHOOK_URL || 'https://pay.toandz.id.vn/payos-webhook';

try {
  const result = await payos.webhooks.confirm(url);
  console.log('✅ Đã đăng ký webhook:', url);
  console.log('   PayOS trả về:', JSON.stringify(result));
} catch (e) {
  console.error('❌ Đăng ký webhook lỗi:', e.message);
  console.error('   Kiểm tra: URL có HTTPS + public không, /payos-webhook có trả 200 không.');
  process.exit(1);
}
