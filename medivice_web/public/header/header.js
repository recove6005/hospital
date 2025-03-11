// 모든 HTML 페이지의 </body> 태그 직전에 이 스크립트를 추가
document.addEventListener('DOMContentLoaded', function() {
    fetch('/header/header.html')
        .then(response => response.text())
        .then(data => {
            document.querySelector('header').innerHTML = data;
        })
        .catch(error => console.error('헤더를 불러오는데 실패했습니다:', error));
});