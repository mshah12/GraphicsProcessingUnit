#include <stdio.h>
#include <math.h>
#include <fstream>
#include <strstream>
#include <vector>

using namespace std;

int main() {
	int size = 0;
	int tracker = 0;
	unsigned int fixedOne = 0b00000000000000001000000000000000;
	unsigned int fixedNegOne = 0b11111111111111111000000000000000;
	volatile unsigned int * AES_PTR = (unsigned int *) 0x10001200;

	AES_PTR[126] = 0;

	ifstream f("/mnt/host/cube.obj");

	vector<float> xvals;
	vector<float> yvals;
	vector<float> zvals;
	vector<float> faces;

	while(f.eof() == false) {
    char temp;
		char line[128];
		f.getline(line, 128);

		strstream s;
		s << line;

    if(line[0] == 'v') {
      float x;
			float y;
			float z;
      s >> temp >> x >> y >> z;
      xvals.push_back(x);
			yvals.push_back(y);
			zvals.push_back(z);
    }

    if(line[0] == 'f') {
			size++;
  		int faces[3];
      s >> temp >> faces[0] >> faces[1] >> faces[2];
			// printf("Triangle #");
			// printf("%d\n", size);
			for(int i = 0; i < 3; i++) {
				if(xvals[faces[i]-1] == 1) {
					AES_PTR[tracker] = fixedOne;
				}
				else {
					AES_PTR[tracker] = fixedNegOne;
				}
				if(yvals[faces[i]-1] == 1) {
					AES_PTR[tracker + 36] = fixedOne;
				}
				else {
					AES_PTR[tracker + 36] = fixedNegOne;
				}
				if(zvals[faces[i]-1] == 1) {
					AES_PTR[tracker + 72] = fixedOne;
				}
				else {
					AES_PTR[tracker + 72] = fixedNegOne;
				}
				// printf("Vertex #");
				// printf("%u\n", i+1);
				// printf("%u\n", fixedX);
				// printf("%u\n", fixedY);
				// printf("%u\n", fixedZ);
				// printf("\n");
				tracker++;
			}
    }
	}
	AES_PTR[127] = size;
	AES_PTR[126] = 1;
}
