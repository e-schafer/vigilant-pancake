az storage fs file upload -f vollgaz-synapse-azdl --account-name vollgazsynapse -s "scripts\parking_luxembourg_2022-12-01.json"  -p "raw/parking_luxembourg/parking_luxembourg_2022-12-01.json" --overwrite --auth-mode login

az storage fs file upload -f vollgaz-synapse-azdl --account-name vollgazsynapse -s "scripts\parking_luxembourg_2022-12-02.json"  -p "raw/parking_luxembourg/parking_luxembourg_2022-12-02.json" --overwrite --auth-mode login
