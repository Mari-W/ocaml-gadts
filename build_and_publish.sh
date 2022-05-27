{
    node_modules/.bin/marp --html presentation.md
    node_modules/.bin/marp --pdf presentation.md
    node_modules/.bin/marp --pptx presentation.md
} || {
    echo "marp not installed; run `npm install`"
}