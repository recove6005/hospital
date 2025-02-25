// header 
const images = [
    '../images/home-banner1.jpg',
    '../images/home-banner2.jpg',
    '../images/home-banner3.jpg',
    '../images/home-banner4.jpg',
];

let curIndex = 0;
const header = document.querySelector('header');

header.style.backgroundImage = `url(${images[0]})`;
header.style.backgroundSize = 'cover';
header.style.backgroundRepeat = 'no-repeat';
header.style.backgroundPosition = 'center';

function changeBackground() {
    curIndex = (curIndex + 1)%images.length;
    header.style.backgroundImage = `url(${images[curIndex]})`;
}

setInterval(changeBackground, 6000);


// youtube
// iFrame API 스크립트 추가
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

// 유튜브 플레이어 생성
function onYouTubeIframeAPIReady() {
    new YT.Player('auto-video', {
        videoId: 't_VcocROpwM',
        playerVars: {
            autoplay: 1, // 자동재생
            mute: 1, // 무음
            loop: 1, // 반복재생
            playlist: 't_VcocROpwM',
            controls: 0, // 플레이어 컨트롤 숨김
            showinfo: 0, // 영상 정보 숨김
            modestbranding: 1, // 유튜브 로고 최소화
            rel: 1, // 관련 동영상 비활성화
            fs: 0,
            disablekb: 1,
            iv_load_policy: 3
        },
        events: {
            'onReady': function(event) {
                event.target.playVideo(); // 영상 자동 실행
                setTimeout(() => {
                    hideYouTubeOverlay();
                }, 200);
            }
        }
    });
}

document.addEventListener("DOMContentLoaded", function() {
    let iframe = document.getElementById("auto-video");
    if (iframe) {
        iframe.blur(); 
    }
});


window.onYouTubeIframeAPIReady = function() {
    if (typeof YT !== "undefined" && YT.Player) {
        onYouTubeIframeAPIReady();
    } else {
        setTimeout(window.onYouTubeIframeAPIReady, 100);
    }
};