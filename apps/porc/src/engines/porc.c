#pragma INPUT  porcIn_t
#pragma OUTPUT porcOut_t

#pragma OFFLOAD (mspm, mspmIn_t, mspmOut_t)
#pragma OFFLOAD (ascii, asciiIn_t, asciiOut_t)
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
  int incF2;
  incF = mspm(Input.word);
  incF2 = ascii(Input.word);

  Output.idx = incF.match_idx_vec + incF2.integer;
  finish();
}
