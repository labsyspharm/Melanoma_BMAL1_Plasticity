# Cell State Dependent Alteration of Melanoma Plasticity and Immunity by the Circadian Transcription Factor Bmal1
**Authors**: Xue Zhang, Shishir Pant, Cecily Ritch, Hsin-Yao Tang, Hongguang Shao, Harsh Dweep, Yaoyu Gong, Rebekah Brooks, Patricia Brafford, Adam Wolpaw, Lee Yool, Ashani Weeraratna, Amita Sehgal, Meenhard Herlyn, Andrew Kossenkov, David Speicher, Peter Sorger, Sandro Santagata, and Chi V. Dang*

*Corresponding author

## DATA ACCESS
### FILE TYPES AND ACCESS LOCATIONS
Each folder corresponds to a patient sample (N). The following files are available for each patient and are located on Amazon Web Services (AWS). 
 
|File Type            | Description                                                                          | Location|
|--------             | -------------------------------------------------------------------------------------|---------|
|N.ome.tif	          | Stitched multiplex CyCIF image pyramid in ome.tif format                             | AWS     |
|markers.csv          | List of all markers in ome.tif image                                                 | AWS     |

 
 **Images and metadata are available in the bucket at the following AWS location:** lsp-public-data/zhang-2023-melanoma-bmal1-plasticity/

> To browse and download the data use either a graphical file transfer application that supports S3 such as [CyberDuck](https://cyberduck.io), or the [AWS CLI tools](https://aws.amazon.com/cli/). Visit the following Zenodo page for instructions on how to access primary image data associated with this publication: Access Laboratory of Systems Pharmacology Datasets on AWS, DOI: [10.5281/zenodo.10223573](https://doi.org/10.5281/zenodo.10223573).

> To explore the full-resolution data in a web-browser visit: [https://www.cycif.org/data/zang-2023/](https://www.cycif.org/data/zang-2023/)

### FILE LIST

6 cores and their corresponding marker .csv files

**N.ome.tif**

| Condition | File Name                                | File Size (GB) |
| ----------| --------------------------------------   | ----------- |
| EV 1      | LSP12583-EV-1--SOX9-SOX10-KI67.ome.tif   | 3.1         | 
| EV 2      | LSP12583-EV-2--SOX9-SOX10-KI67.ome.tif   | 2.8         |
| WT 1      | LSP12583-WT-1--SOX9-SOX10-KI67.ome.tif   | 2.9         |
| WT 2      | LSP12583-WT-2--SOX9-SOX10-KI67.ome.tif   | 2.9         |
| dHLH-1    | LSP12583-dHLH-1--SOX9-SOX10-KI67.ome.tif | 2.4         |
| dHLH-2    | LSP12583-dHLH-2--SOX9-SOX10-KI67.ome.tif | 3.0         |



**markers.csv**

| Condition | File name           | File Size (MB) |
| ----------| ------------------- |--------------- |
| EV 1      | LSP12583-EV-1.csv   | 97.6           |     
| EV 2      | LSP12583-EV-2.csv   | 93.1           |
| WT 1      | LSP12583-WT-1.csv   | 108.0          |
| WT 2      | LSP12583-WT-2.csv   | 84.5           |
| dHLH-1    | LSP12583-dHLH-1.csv | 68.1           |
| dHLH-2    | LSP12583-dHLH-2.csv | 122.5          |
