#version 440

layout(binding = 0) buffer dcA1 { float A1 []; };
layout(binding = 1) buffer dcA2 { float A2 []; };
layout(binding = 2) buffer dcB1 { float B1 []; };
layout(binding = 3) buffer dcB2 { float B2 []; };
layout(rgba8, binding = 4) uniform writeonly image2D img;
layout(local_size_x = 20, local_size_y = 20, local_size_z = 1) in;


uint hash(uint state) 
{
	state ^= 2747636419u;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	state ^= state >> 16;
	state *= 2654435769u;
	return state;
}

int per(int x, int nx) 
{
	if (x < 0) x += nx;
	if (x >= nx) x -= nx;
	return x;
}

vec4 color(float t)
{
	float coltab[]={0.5,0.5,0.5,0.5,0.5,0.5,1.0,0.7,0.4,0.00,0.15,0.20};

	vec4 col;
	col.r = coltab[0]+coltab[3]*cos(2*3.1416*(coltab[6]*t+coltab[9]));
	col.g = coltab[1]+coltab[4]*cos(2*3.1416*(coltab[7]*t+coltab[10]));
	col.b = coltab[2]+coltab[5]*cos(2*3.1416*(coltab[8]*t+coltab[11]));
	col.a = 1;
	return col;
}

void main()
{
	int i, j;
	i = int(gl_GlobalInvocationID.x);
	j = int(gl_GlobalInvocationID.y);

	const int W = 1080;
	const int H = 720;
	int idx = i + j * W;

	float DA = 1.0;
	float DB = 0.4;
	float f = 0.04;
	float k = 0.065;

	float h = 0.5 * i / float(W);
	f = 0.02 * h + (1 - h) * 0.018;
	k = 0.035 * h + (1 - h) * 0.051;

	float dt = 1.0;
	int idx0, idx1, idx2, idx3, idx4, idx5, idx6, idx7, idx8;
	int ip, jp, im, jm;

	ip = per(i + 1, W);
	im = per(i - 1, W);
	jp = per(j + 1, H);
	jm = per(j - 1, H);
	idx0 = i+W*j;            // neighbours
    idx1 = ip+W*(jp);
    idx2 = ip+W*(j);        // i+1,j
    idx3 = ip+W*(jm);
    idx4 = i+W*(jm);        // i,j-1
    idx5 = im+W*(jm);
    idx6 = im+W*(j);        // i-1, j
    idx7 = im+W*(jp);
    idx8 = i+W*(jp);        // i, j+1

    // laplacians
    float laplA = -1.0 * A1[idx0] + .2 * (A1[idx6] + A1[idx2] + A1[idx4] + A1[idx8]) + 0.05 * (A1[idx1] + A1[idx3] + A1[idx5] + A1[idx7]);
    float laplB = -1.0 * B1[idx0] + .2 * (B1[idx6] + B1[idx2] + B1[idx4] + B1[idx8]) + 0.05 * (B1[idx1] + B1[idx3] + B1[idx5] + B1[idx7]);

    // Gray Scott model
    A2[idx0] = A1[idx0] + (DA * laplA - A1[idx0] * B1[idx0] * B1[idx0]                 + f * (1 - A1[idx0])) * dt;
    B2[idx0] = B1[idx0] + (DB * laplB + A1[idx0] * B1[idx0] * B1[idx0]                 - (k+f) * B1[idx0]) * dt;

    // visualization
    float a = A2[idx];
    float b = B1[idx];
    vec4 col = color(1.51*a+1.062*b);

    imageStore(img,ivec2(gl_GlobalInvocationID.xy),col);
}