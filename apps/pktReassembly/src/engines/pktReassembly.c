#pragma INPUT  metadata_t
#pragma OUTPUT metadata_t

#pragma OFFLOAD (dynamicMem, dyMemInput_t, llNode_t)
#pragma OFFLOAD (hash, tuple_t, fce_meta_t)
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
  int hashed;

  incF = dynamicMem(Input.seq);
  hashed = hash(Input.seq);
  Output.seq = incF + Input.seq + hashed;
  finish();
}
