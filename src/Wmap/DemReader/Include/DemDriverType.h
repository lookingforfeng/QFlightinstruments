#pragma once

//支持的驱动力类型，目前仅支持GTiff
namespace HQDTEDReader {
	enum eDriverType {
		TypeFloor = 0,
		GTiff,
		PNG,
		JPEG,
		GIF,
		BMP,
		ALLType,
		TypeUpper
	};
}

