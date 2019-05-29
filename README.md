# AppCESM #

These files are used to adapt the Community Earth System Model [CESM](http://www.cesm.ucar.edu) to be used with a Scife system. The system has been tested with CESM [v1.2.2](http://www.cesm.ucar.edu/models/cesm1.2/).

## Usage and installation ##

* Download a copy of CESM software from its webpage and extract on a target folder.
* Overwrite the CESM files on the target folder with the files of this project.
* Use Scife to create the application with the contents of the target folder, e.g. using the `create_application` command of Scife's CLI. The compilation script must be set to `create_experiment.sh` and the execution script must be set to `execute_experiment.sh`.
