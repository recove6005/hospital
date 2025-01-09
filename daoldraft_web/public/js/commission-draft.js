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

            document.getElementById("user-email").innerText = result.msg;
            
            document.getElementById("to-signin").style.display = 'none';
        }
    }
}
checkUserVerify();

// 연락처 input 문자열
document.getElementById('input-phone').addEventListener("input", function (e) {
    let input = e.target.value;

    // 숫자만 남기기
    input = input.replace(/[^0-9]/g, "");

    // 3-3-4 형식으로 포맷팅
    if (input.length <= 3) {
        e.target.value = input; // 3자리 이하일 경우 그대로 출력
    } else if (input.length <= 7) {
        e.target.value = input.slice(0, 3) + "-" + input.slice(3); // 3-4 형식
    }
    else if(input.length <= 10) { // 10자리 3-3-4 형식
        e.target.value = input.slice(0, 3) + "-" + input.slice(3, 6) + "-" + input.slice(6);
    }
    else if(input.length > 10) { // 11자리 3-4-4 형식
        e.target.value = input.slice(0, 3) + "-" + input.slice(3, 7) + "-" + input.slice(7);
    }

});

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

// 가격 정보
function getPrice(membersheType) {
    const priceElement = document.getElementById('price');
    const discountPriceElement = document.getElementById('discount-price');
    const allprice = document.getElementById('allprice');

    if(membersheType === '1') {
        discountPriceElement.style.display = 'block';
        discountPriceElement.textContent = '28,500 원';
        priceElement.style.textDecoration = 'line-through';
        allprice.value = '28500';
    }
    else if(membersheType === '2') {
        discountPriceElement.style.display = 'block';
        discountPriceElement.textContent = '27,000 원';
        priceElement.style.textDecoration = 'line-through';
        allprice.value = '27000';
    }
    else if(membersheType === '3') {
        discountPriceElement.style.display = 'block';
        discountPriceElement.textContent = '21,000 원';
        priceElement.style.textDecoration = 'line-through';
        allprice.value = '21000';
    }
    else {
        discountPriceElement.style.display = 'none';
        priceElement.style.textDecoration = 'none';
        allprice.value = '30000';
    }
}

// 사용자 구독권 정보 가져오기
async function getSubscribeType() {
    var membersheType = '0';
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        membersheType = result.subscribe;
    } else {
        console.log(`error: ${result.error}`);
    }

    return membersheType;
}

getPrice(await getSubscribeType());

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
        console.log(result.msg);

        // 드롭다운 메뉴 숨기기
        const dropdownMenu = document.getElementById('dropdown-menu');
        dropdownMenu.style.display = 'none';

        // 프로필 구역 UI변경
        document.getElementById("profile-photo").style.visibility = 'hidden';
        document.getElementById("profile-photo").style.display = 'none';

        document.getElementById("to-signin").style.visibility = 'visible';
        document.getElementById("to-signin").style.display = 'block';

        window.location.href="../html/home.html";
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});

// 프로젝트 문의 등록
document.getElementById('contact-form').addEventListener('submit', async (e) => {
    e.preventDefault();

    const formData = new FormData(e.target);
    const formValues = Object.fromEntries(formData.entries());

    const loginCheckRes = await fetch('/login/current-user', {
        method: 'POST',
        credentials: "include",
    });

    if(loginCheckRes.ok) {
        try {
            const response = await fetch('/user/commission-project-draft', {
                method: 'POST',
                credentials: "include",
                headers: { "Content-Type" : "application/json" },
                body: JSON.stringify(formValues),
            });

            const result = await response.json();
            if(response.ok) {
                alert('프로젝트가 접수되었습니다. 마이페이지에서 확인해 주세요.');
                window.location.href = '../html/home.html';
            } else {
                console.log(result.error);
            }
        } catch(e) {
            console.error("error: ", e);
        } 
    } else {
        window.location.href = '../html/login-email.html';
    }
});