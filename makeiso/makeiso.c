#include <stdio.h>

static const char usagestr[] =
	"USAGE:\n"
	"  makeiso [options] <binary files>\n"
	"\n"
	"OPTIONS:\n"
	"  -imagename=$1    sets the image name (default: 'image.iso')\n"
	"  -sectorsize=$1   sets sector size to $1 (default: 512)\n"
	"  -s$1:$2          subsequent files are added in order to\n"
	"                   sector $1, offset $2 (default: 0:0)\n";
static void usage(void){
	puts(usagestr);
}

static int sectorsize = 512;
static int fileoffset = 0;
static FILE *iso = NULL;
static const char *isoname = "image.iso";

static void cleanup(void){
	if(iso != NULL)
		fclose(iso);
}

int main(int argc, char **argv){
	if(argc < 2){
		// expect at least one binary file
		usage();
		return -1;
	}

	atexit(cleanup);

	for(int i = 1; i < argc; i += 1){
		if(argv[i][0] == '-'){
			// parse option
			int sector, offset;
			if(strncmp("imagename=", &argv[i][1], 10) == 0){
				isoname = &argv[i][11];
				printf("image name set to '%s'\n", isoname);
			}else if(strncmp("sectorsize=", &argv[i][1], 11) == 0){
				sectorsize = atoi(&argv[i][12]);
				printf("sectorsize set to '%d'\n", sectorsize);
			}else if(argv[i][1] == 's'
			  && sscanf(&argv[i][2], "%d:%d", &sector, &offset) == 2){
				printf("sector: %d, offset: %d\n", sector, offset);
				fileoffset = sector * sectorsize + offset;
				if(iso != NULL)
					fseek(iso, fileoffset, SEEK_SET);
			}else{
				printf("skipping invalid option: '%s'\n", argv[i]);
			}
		}else{
			// add file
			#define COPYBUF_SIZE 4096
			FILE *bin;
			const char *binname = argv[i];
			char copybuf[COPYBUF_SIZE];
			size_t read, written;
	
			if(iso == NULL){
				iso = fopen(isoname, "wb");
				if(iso == NULL){
					printf("failed to open image file '%s' for writing\n", isoname);
					printf("unable to proceed\n");
					return -1;
				}
				fseek(iso, fileoffset, SEEK_SET);
			}

			bin = fopen(binname, "rb");
			if(bin == NULL){
				printf("failed to open binary file '%s' for reading\n", binname);
				printf("skipping...\n");
				continue;
			}

			do{
				read = fread(copybuf, 1, COPYBUF_SIZE, bin);
				if(read > 0){
					written = fwrite(copybuf, 1, read, iso);
					if(read != written){
						printf("failed to write copybuffer into"
							" the image file (expected = %d,"
							" written = %d)\n", (int)read, (int)written);
						fclose(bin);
						return -1;
					}
				}
			}while(read == COPYBUF_SIZE);

			fclose(bin);
		}
	}
	return 0;
}