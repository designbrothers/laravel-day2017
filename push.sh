echo > 'PITCHME.md'

for file in ./chapters/*.md
do
    cat $file >> ./PITCHME.md
    echo -e "\n---" >> 'PITCHME.md'
done

sed -i '$ d' 'PITCHME.md'

git add . -A && git commit -m "code-updated" && git push origin master