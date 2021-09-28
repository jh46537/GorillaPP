#pragma INPUT  uint128_t
#pragma OUTPUT uint128_t

GS_GET() {
  Output = 2;
  State = GS_SEND;
}

GS_SEND() {
  finish();
}
