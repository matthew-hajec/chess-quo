copy_btn = document.getElementById("copy-link-btn");

if (copy_btn) {
    copy_btn.addEventListener("click", function(event) {
        event.preventDefault();
        const url = this.getAttribute("data-url");
        
        navigator.clipboard.writeText(url)
    });
}