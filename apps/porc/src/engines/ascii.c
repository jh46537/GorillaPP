#pragma INPUT  asciiIn_t
#pragma OUTPUT asciiOut_t

GS_GET() {
  Output = 2;
  State = GS_SEND;
}

GS_SEND() {
  finish();
}
