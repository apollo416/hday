rm -rf ./python

pip install --no-binary ":all:" -r requirements.txt -t python

zip -r layer_content.zip python
