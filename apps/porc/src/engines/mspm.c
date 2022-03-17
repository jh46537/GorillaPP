#pragma INPUT  mspmIn_t
#pragma OUTPUT mspmOut_t

GS_GET() {
  Output = 2;
  State = GS_SEND;
}

GS_SEND() {
  finish();
}
