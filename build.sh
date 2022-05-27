{
    node_modules/.bin/marp slides.md -o index.html
    node_modules/.bin/marp slides.md -o handout.pdf
} || {
    echo "marp not installed; run `npm install`"
}