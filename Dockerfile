# Stage 1: Builder
FROM node:20-bookworm AS builder

WORKDIR /app

# Khai báo file lock để đảm bảo cài đặt dependencies chính xác tuyệt đối
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy mã nguồn và thực thi tiến trình build
COPY . .
RUN yarn build

# Stage 2: Runner
FROM node:20-bookworm-slim AS runner

ENV NODE_ENV=production
WORKDIR /app

# Cài đặt các thư viện hệ thống (chỉ phục vụ runtime)
# Bao gồm client để tương tác Postgres và các font chữ để xuất file PDF
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    libfreetype6 \
    fontconfig \
    fonts-liberation \
    fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy kết quả từ stage builder và cấp quyền cho user 'node'
COPY --from=builder --chown=node:node /app /app

# Tạo sẵn thư mục storage và đảm bảo user 'node' có quyền ghi
RUN mkdir -p /app/storage/uploads && chown -R node:node /app/storage

# Chuyển xuống quyền non-root để tăng cường bảo mật
USER node

# Mở cổng mục tiêu 3000
EXPOSE 3000

# Khởi chạy ứng dụng Nocobase
CMD ["yarn", "start"]