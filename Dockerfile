FROM rust:1.79-slim
COPY ./ ./
RUN cargo build --release

ENV ROCKET_ADDRESS=0.0.0.0
EXPOSE 8000
CMD ["./target/release/rust-backend-aws"]