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

// 구독권에 따른 가격 표시
function getPrice(membersheType, sizeValue) {
    const priceElement = document.getElementById('price');
    const titleElement = document.getElementById('project-name');
    const discountPriceElement = document.getElementById('discount-price');
    const allprice = document.getElementById('allprice');

    if(membersheType === '1') {
        // 월간 3만원 구독권 사용자
        if (sizeValue === '하') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '1,425,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '1,500,000 원';
            titleElement.textContent = '홈페이지 디자인 (하)';
            allprice.value = '1425000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '2,850,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '3,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (중)';
            allprice.value = '2850000';
        } 
        else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = ' 4,750,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '5,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (상)';
            allprice.value = '4750000';
        }
    }
    else if(membersheType === '2') {
        // 월간 5만원 구독권 사용자
        if (sizeValue === '하') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '1,350,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '1,500,000 원';
            titleElement.textContent = '홈페이지 디자인 (하)';
            allprice.value = '1350000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '2,700,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '3,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (중)';
            allprice.value = '2700000';
        } 
        else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = ' 4,500,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '5,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (상)';
            allprice.value = '4500000';
        }
    } 
    else if(membersheType === '3') {
        // 연간 50만원 구독권 사용자
        if (sizeValue === '하') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '1,050,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '1,500,000 원';
            titleElement.textContent = '홈페이지 디자인 (하)';
            allprice.value = '1050000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '2,100,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '3,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (중)';
            allprice.value = '2100000';
        } 
        else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '3,500,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '5,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (상)';
            allprice.value = '3500000';
        }
    }
    else if(membersheType === '0') {
        // 구독권이 없는 사용자
        if (sizeValue === '하') {
            discountPriceElement.style.display = 'none';
            priceElement.style.textDecoration = 'none';
            priceElement.textContent = '1,500,000 원';
            titleElement.textContent = '홈페이지 디자인 (하)';
            allprice.value = '1500000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'none';
            priceElement.style.textDecoration = 'none';
            priceElement.textContent = '3,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (중)';
            allprice.value = '3000000';
        } 
        else {
            discountPriceElement.style.display = 'none';
            priceElement.style.textDecoration = 'none';
            priceElement.textContent = '5,000,000 원';
            titleElement.textContent = '홈페이지 디자인 (상)';
            allprice.value = '5000000';
        }
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

// 구독권 가격 초기 가격
getPrice(await getSubscribeType(), '하');


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
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});


const radios = document.querySelectorAll('input[name="size"]');
radios.forEach((radio) => {
    radio.addEventListener('click', async function() {
        const sizeValue = this.value;
        const membersheType = await getSubscribeType();
        
        getPrice(membersheType, sizeValue);
    });
});

// 프로젝트 문의 로직
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
            const response = await fetch('/user/commission-project-homepage', {
                method: 'POST',
                credentials: "include",
                headers: { "Content-Type" : "application/json "},
                body: JSON.stringify(formValues),
            });
    
            const result = await response.json();
            if(response.ok) {
                alert('프로젝트가 접수됐습니다. 마이페이지에서 확인해 주세요.');
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

