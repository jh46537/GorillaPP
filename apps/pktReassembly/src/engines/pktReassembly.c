#pragma INPUT  insertIfc_t
#pragma OUTPUT insertIfc_t

#pragma OFFLOAD (dynamicMem, uint128_t, uint128_t)
#pragma CONCURRENT_SAFE

int counter;

GS_INITIALIZE () {
  counter = 10;
  State = GS_COUNT;
}

GS_COUNT () {
  if (counter == 0) {
    State = GS_GET_INC_FACTOR;
  }
  counter = counter - 1;
}

GS_GET_INC_FACTOR () {
  int incF;

  incF = dynamicMem(Input.pkt);
  Output.pkt.seq = incF + Input.pkt.seq;
  finish();
}
