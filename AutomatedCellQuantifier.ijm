/**
 *This macro is intended to record the fluorescence and area of
 *individual cells through batch processing
 *
 *The program prompts the user to select a folder containing all the images of
 *cells. Then, the user most also pick an output folder. If the user wants
 *to see how the program automatically outlined the contours of the cells
 *(regions of interest), the user drops the specific output photo back into
 * imageJ.
 *
 *The user can also designate a minumum density brightness to remove cells width
 *a low fluorescence or false positives (fluorescence binding to background
 *tissue rather than cell of interest)
 *
 *Easily modifiable to include other statistics by changing the "analyze
 *  particle" function to include different Measurements.
 *
 *Created by Ryan Guan 7/14/17
 */


densBrightThreshold = 10;

run("Set Measurements...", "area mean min integrated display redirect=None decimal=3");
roiManager("reset");

dir1 = getDirectory("Input");
format = getFormat();
dir2 = getDirectory("Output ");
list = getFileList(dir1);
setBatchMode(true);
function getFormat()
{     formats = newArray("TIFF", "8-bit TIFF", "JPEG", "GIF", "PNG", "PGM", "BMP", "FITS", 	"Text Image", "ZIP", "Raw");
	Dialog.create("Batch Convert");
	Dialog.addChoice("Convert to: ", formats, "TIFF");
	Dialog.show();
	return Dialog.getChoice();
}

for (i=0; i<list.length; i++)
 {
 	showProgress(i+1, list.length);
	open(dir1+list[i]);
	title=getTitle();
	selectWindow(title);

	run("Make Binary");
	run("Analyze Particles...", "size=15-Infinity show=Overlay add");
	close();

	open(dir1+list[i]);
	roiManager("measure");

	for (z = 0; z < nResults; z++){
	intDensity = getResult("IntDen", z);
	area = getResult("Area", z);
	densBright = intDensity / area;
	if (densBright < densBrightThreshold) {
 	 IJ.deleteRows(z, z);
  		}
	}

	roiManager("Show All");
	run("Flatten");
	close();
	saveAs("Tiff", dir2+list[i]);

	roiManager("reset");
}

function convertTo8Bit() {
	if (bitDepth==24)
		run("8-bit Color", "number=256");
	else
		run("8-bit");
}
