{
    node_modules/.bin/marp slides.md --html -o index.html
    node_modules/.bin/marp slides.md --html -o handout.pdf
} || {
    echo "marp not installed; run `npm install`"
}       