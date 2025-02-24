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

    if(response.status == 200) {
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
        dropdownMenu.style.display = 'block';
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


        if(response.ok) {
            const error = await response.json();
            console.error("Logout failed:", error.msg || "Unknown error");
            alert(`Error: ${error.msg || "Logout failed."}`);
            return;
        }

        const result = response.data;
        console.log(result.msg);

        // 드롭다운 메뉴 숨기기
        const dropdownMenu = document.getElementById('dropdown-menu');
        dropdownMenu.style.display = 'none';

        // 프로필 구역 UI변경
        document.getElementById("profile-photo").style.visibility = 'hidden';
        document.getElementById("profile-photo").style.display = 'none';

        document.getElementById("to-signin").style.visibility = 'visible';
        document.getElementById("to-signin").style.display = 'block';

        window.location.href="../page/home.html";
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});

// 구독권 정보 가져오기
async function getSubscribeType() {
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
    });

    const result = await response.json();
    if(response.ok) {
        console.log(`type: ${result.subscribe}`);
        return result.subscribe;
    } else {
        console.log(`eroor: ${result.error}`);
        return '';
    }
}

document.getElementById('type1').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();

    if(subscribeType === '0') {
        // 구독권 없음, 초기 결제
     
    }
    // 이미 구매한 구독권이 있음
    else if(subscribeType==='1') alert(`회원님은 현재 이미 [베이직] 구독권 이용 중입니다.`);
    else if(subscribeType==='2') alert(`회원님은 현재 [스텐다드] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
    else if(subscribeType==='3') alert(`회원님은 현재 [프리미엄] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
});

document.getElementById('subscribe-type2').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();
    
    if(subscribeType === '0') {
        // 구독권 없음, 초기 결제
     
    }
    // 이미 구매한 구독권이 있음
    else if(subscribeType==='1') alert(`회원님은 현재 [베이직] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
    else if(subscribeType==='2') alert(`회원님은 현재 이미 [스텐다드] 구독권 이용 중입니다.`);
    else if(subscribeType==='3') alert(`회원님은 현재 [프리미엄] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
});

document.getElementById('subscribe-type3').addEventListener('click', async (e) => {
    const subscribeType = await getSubscribeType();
    
    if(subscribeType === '0') {
        // 구독권 없음, 초기 결제
     
    }
    // 이미 구매한 구독권이 있음
    else if(subscribeType==='1') alert(`회원님은 현재 [베이직] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
    else if(subscribeType==='2') alert(`회원님은 현재 [스텐다드] 구독권 이용 중입니다. 구독권을 변경하려면 기존 구독권을 해지해주세요.`);
    else if(subscribeType==='3') alert(`회원님은 현재 이미 [프리미엄] 구독권 이용 중입니다.`);
});
