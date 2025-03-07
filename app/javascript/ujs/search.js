function ajaxSuccessHandler(xhr) {
    const movies = document.querySelector("#movies")
    movies.style.opacity = 1;
}

function ajaxErrorHandler(xhr) {
    const movies = document.querySelector("#movies")
    movies.innerHTML = '<p class="alert alert-danger">Sorry, but something went wrong!</p>';
    movies.style.opacity = 1;
}

window.linkAjaxEvents = () => {
    const links = document.querySelectorAll("a[data-remote]");
    links.forEach((link) => {
        link.addEventListener("ajax:success", (xhr) => {
            ajaxSuccessHandler(xhr);
        });
        link.addEventListener("ajax:error", (xhr) => {
            ajaxErrorHandler(xhr)
        });
    });
}

window.addEventListener('load', () => {

    const movies = document.querySelector("#movies")

    document.body.addEventListener('ajax:send', (xhr) => {
        movies.innerHTML = '<img src="Loading-bar.gif" class="loader" />'
        movies.style.opacity = 0.2;
    })

    document.body.addEventListener('ajax:success', (xhr) => {
        ajaxSuccessHandler(xhr)
    })

    document.body.addEventListener('ajax:error', (xhr) => {
        ajaxErrorHandler(xhr)
    })

    window.linkAjaxEvents()

})
