// 로그인 체크
async function checkLogin() {
    const response = await fetch('/login/current-user', {
        method: 'POST',
        credentials: "include",
    });

    if(response.ok) {
        document.getElementById("profile-photo").style.visibility = 'visible';
        document.getElementById("profile-photo").style.display = 'flex';
        document.getElementById("profile-photo").style.flexDirection = 'raw';
        document.getElementById("profile-photo").style.alignItems = 'center';            
        document.getElementById("to-signin").style.display = 'none';
    } else {
        document.getElementById("to-signin").style.display = 'block';
    }
}
checkLogin();

// async function checkUserVerify() {
//     const response = await fetch('/login/verify', {
//         method: 'POST',
//         credentials: "include",
//     });

//     const result = await response.json();

//     if(response.ok) {
//         if(result.msg.includes("verify0")) {
//             window.location.reload();

//             alert('인증 이메일이 전송되었습니다. 인증 완료 후 다시 로그인해 주세요.');
//             document.getElementById("to-signin").style.display = 'block';
//         } 
//         else {
//             document.getElementById("profile-photo").style.visibility = 'visible';
//             document.getElementById("profile-photo").style.display = 'flex';
//             document.getElementById("profile-photo").style.flexDirection = 'raw';
//             document.getElementById("profile-photo").style.alignItems = 'center';            
//             document.getElementById("to-signin").style.display = 'none';
//         }
//     }
// }
// checkUserVerify();

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
    window.location.href = "/page/login-email.html";
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

        window.location.href = '../page/home.html';
    } catch(e) {
    console.error("Unexpected error during logout:", error);
    alert("An unexpected error occurred. Please try again.");
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