
// 로그인 체크
async function checkLogin() {
    const response = await fetch('/login/current-user', {
        method: 'POST',
        credentials: "include",
    });

    if(!response.ok) {
        document.getElementById("to-signin").style.display = 'block';
    }
}
checkLogin();

async function checkUserVerify() {
    const response = await fetch('/login/verify', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();

    if(response.ok) {
        if(result.msg.includes("verify0")) {
            window.location.reload();
            alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
            document.getElementById("to-signin").style.display = 'block';
        } 
        else {
            document.getElementById("profile-photo").style.visibility = 'visible';
            document.getElementById("profile-photo").style.display = 'flex';
            document.getElementById("profile-photo").style.flexDirection = 'raw';
            document.getElementById("profile-photo").style.alignItems = 'center';            
            document.getElementById("to-signin").style.display = 'none';
        }
    }
}
checkUserVerify();

// 드롭다운 관리자 계정 전용 링크 설정
async function checkUserAdminAndDisplay() {
    const response = await fetch('/login/check-admin', {
        method: 'POST',
        credentials: "include",  
    });

    const result = await response.json();

    if(response.ok) {
        if(result.admin) document.getElementById('dropdown-management').style.display = 'block';  
        else document.getElementById('dropdown-management').style.display = 'none';  
    } else {
        console.log(`error: ${result.error}`);
    }
}
checkUserAdminAndDisplay();

// Profile link 클릭 시 드롭다운 토글
document.getElementById('profile-link').addEventListener('click', function (e) {
    e.preventDefault(); // 기본 앵커 동작 방지
    const dropdownMenu = document.getElementById('dropdown-menu');
    
    // 드롭다운 메뉴 보이기/숨기기
    if (dropdownMenu.style.display === 'none' || dropdownMenu.style.display === '') {
        dropdownMenu.style.display = 'flex';
    } else {
        dropdownMenu.style.display = 'none';
    }
});

// 다른 영역 클릭 시 드롭다운 닫기
document.addEventListener('click', function (e) {
    const dropdownMenu = document.getElementById('dropdown-menu');
    const profilePhoto = document.getElementById('profile-photo');

    if (!profilePhoto.contains(e.target)) {
        dropdownMenu.style.display = 'none';
    }
});

document.getElementById("to-signin").addEventListener('click', () => {
    window.location.href = "/html/login-email.html";
});

// 드롭다운 메뉴 로그아웃
document.getElementById("dropdown-logout").addEventListener('click', async (e) => {
    try {
        const response = await fetch('/login/logout', {
            method: 'POST',
            credentials: 'include',
        });

        if(!response.ok) {
            const error = await response.json();
            console.error("Logout failed:", error.msg || "Unknown error");
            alert(`Error: ${error.msg || "Logout failed."}`);
            return;
        }

        const result = await response.json();

        window.location.href = '../html/home.html';
    } catch(e) {
    console.error("Unexpected error during logout:", error);
    alert("An unexpected error occurred. Please try again.");
    }
});

// portfolio 버튼 이벤트
document.getElementById('service-prev-btn').addEventListener('click', (e) => {
    e.preventDefault();
    const serviceContainer1 = document.getElementById('service-container-1');
    const serviceContainer2 = document.getElementById('service-container-2');

    if(serviceContainer1.style.transform === 'translateX(-971px)') {
        serviceContainer1.style.transform = 'translateX(0px)';
        serviceContainer2.style.transform = 'translateX(0px)';
    }
});

document.getElementById('service-next-btn').addEventListener('click', (e) => {
    e.preventDefault();
    const serviceBox = document.getElementById('service-container-box');
    const serviceContainer1 = document.getElementById('service-container-1');
    const serviceContainer2 = document.getElementById('service-container-2');

    if(serviceContainer1.style.transform = 'translateX(0px)') {
        serviceContainer1.style.transform = 'translateX(-971px)';
        serviceContainer2.style.transform = 'translateX(-971px)';
    }
});



// 1200px 이하 유저 메뉴 리스트 열기
document.getElementById('menu-display-btn').addEventListener('click', (e) => {
    const menus = document.getElementById('user-container');
    if(menus.style.left === '0px') {
        console.log('ddd');
        menus.style.left = '-200px';
    } else {
        menus.style.left = '0';
    }
});

// 1200px 이하 유저 메뉴 리스트 닫기
document.addEventListener('click', function (e) {
    const menus = document.getElementById('user-container');
    const btn = document.getElementById('menu-display-btn');
    if (!menus.contains(e.target) && !btn.contains(e.target)) {
        menus.style.left = '-200px';
    }
});

const serviceImage = document.getElementById('service-description-image');
const serviceTitle = document.getElementById('service-description-title-span');
const serviceContent = document.getElementById('service-description-content');
const serviceBtn = document.getElementById('service-see-detail-btn');

// service section
// document.querySelectorAll('.service-tab').forEach(item => {
//     item.addEventListener('click', (e) => {
//         e.preventDefault();
//         console.log(`clicked. ${e.target.id}`);
//     });
// });

// document.getElementById('service-tab-homepage').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services2.png';
//     serviceTitle.innerText = '홈페이지 제작';
//     serviceContent.innerText = '홈페이지 디자인/제작/배포 및 맞춤형 모바일 앱 제작';
//     serviceBtn.href = '../html/commission-homepage.html';
// });

// document.getElementById('service-tab-logo').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services3.png';
//     serviceTitle.innerText = '로고 디자인';
//     serviceContent.innerText = '로고 디자인 및 제작. 크기별 상/중/하.';
//     serviceBtn.href = '../html/commission-logo.html';
// });

// document.getElementById('service-tab-blog').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services4.png';
//     serviceTitle.innerText = '네이버 블로그';
//     serviceContent.innerText = '네이버 블로그 원고 작성과 포스팅 및 운영';
//     serviceBtn.href = '../html/commission-blog.html';
// });

// document.getElementById('service-tab-instagram').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services5.png';
//     serviceTitle.innerText = 'SNS';
//     serviceContent.innerText = '인스타그램 등 SNS 홍보 게시물 제작과 포스팅 및 운영';
//     serviceBtn.href = '../html/commission-instagram.html';
// });

// document.getElementById('service-tab-naverplace').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services6.png';
//     serviceTitle.innerText = '네이버 플레이스 등록';
//     serviceContent.innerText = '네이버 장소 검색 노출';
//     serviceBtn.href = '../html/commission-naverplace.html';
// });

// document.getElementById('service-tab-draft').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services7.png';
//     serviceTitle.innerText = '원내시안';
//     serviceContent.innerText = '---';
//     serviceBtn.href = '../html/commission-draft.html';
// });

// document.getElementById('service-tab-signage').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services8.png';
//     serviceTitle.innerText = '디지털 사이니지';
//     serviceContent.innerText = '디지털 LED 디스플레이에 게시할 광고게시판 포스터 디자인 및 제작';
//     serviceBtn.href = '../html/commission-signage.html';

// });

// document.getElementById('service-tab-banner').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services9.png';
//     serviceTitle.innerText = '웹 배너';
//     serviceContent.innerText = '홈페이지 등 웹 사이트에 표시할 배너 디자인 및 제작';
//     serviceBtn.href = '../html/commission-webbanner.html';

// });

// document.getElementById('service-tab-video').addEventListener('click', (e) => {
//     e.preventDefault();
//     serviceImage.src = '../images/aligo_services10.png';
//     serviceTitle.innerText = '영상';
//     serviceContent.innerText = '홍보 영상 제작 및 편집';
//     serviceBtn.href = '../html/commission-video.html';
// });