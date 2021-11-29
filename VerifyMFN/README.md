# MobileFaceNet model verification
The purpose of this project is to verify
the correctness of the MobileFaceNet model.

Thus, this project by now doesn't include any GUI.
The "entry point" of this project is in androidTest/java/ProcessLFWTest, which should be run as Test-


The coded downloads the labeled faces in the wild dataset
from the official site, and computes its embeddings using the MFN model.

The results are stored into a SQLite database "db".




