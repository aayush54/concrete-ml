"A script to generate all development files necessary for the image filtering demo."

import numpy as np
import onnx
import shutil
from pathlib import Path 

from custom_client_server import CustomFHEDev
from filters import Filter
from common import FILTERS_PATH, AVAILABLE_FILTERS, INPUT_SHAPE, INPUTSET


print("Generating deployment files for all available filters")

for image_filter in AVAILABLE_FILTERS:
    print("Filter:", image_filter, "\n")

    # Create the filter instance
    filter = Filter(image_filter)

    image_shape = INPUT_SHAPE + (3,)

    # Compile the filter on the inputset
    filter.compile(INPUTSET)

    filter_path = FILTERS_PATH / image_filter

    deployment_path = filter_path / "deployment"

    # Delete the deployment folder and its content if it exist
    if deployment_path.is_dir():
        shutil.rmtree(deployment_path)

    # Save the files needed for deployment 
    fhe_dev_filter = CustomFHEDev(deployment_path, filter)
    fhe_dev_filter.save()

    # Save the ONNX mdel
    onnx.save(filter.onnx_model, filter_path / "server.onnx")

print("Done !")