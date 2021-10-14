#pragma INPUT  tuple_t
#pragma OUTPUT fce_meta_t

GS_GET() {
  Output = 2;
  State = GS_SEND;
}

GS_SEND() {
  finish();
}
