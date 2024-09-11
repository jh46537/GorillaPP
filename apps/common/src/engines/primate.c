#pragma INPUT  input_t
#pragma OUTPUT output_t

#pragma CONCURRENT_SAFE

int counter;

GS_INITIALIZE () {
  counter = 10;
  State = GS_COUNT;
}

GS_COUNT () {
  counter = counter + 1;
  State = GS_GET_INC_FACTOR;
}

GS_GET_INC_FACTOR () {
  Output.data = counter + Input.data;
  finish();
}
