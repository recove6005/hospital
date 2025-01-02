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

// 구독권에 따른 가격 표시
function getPrice(membersheType, sizeValue) {
    const priceElement = document.getElementById('price');
    const titleElement = document.getElementById('project-name');
    const discountPriceElement = document.getElementById('discount-price');
    const allprice = document.getElementById('allprice');

    if(membersheType === '1') {
        // 월간 3만원 구독권 사용자
        if (sizeValue === '상') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '475,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '500,000 원';
            titleElement.textContent = '로고 디자인 (상)';
            allprice.value = '457000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '285,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '300,000 원';
            titleElement.textContent = '로고 디자인 (중)';
            allprice.value = '285000';
        } else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '142,500 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '150,000 원';
            titleElement.textContent = '로고 디자인 (하)';
            allprice.value = '142500';
        }
    }
    else if(membersheType === '2') {
        // 월간 5만원 구독권 사용자
        if (sizeValue === '상') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '450,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '500,000 원';
            titleElement.textContent = '로고 디자인 (상)';
            allprice.value = '450000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '270,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '300,000 원';
            titleElement.textContent = '로고 디자인 (중)';
            allprice.value = '270000';
        } else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '135,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '150,000 원';
            titleElement.textContent = '로고 디자인 (하)';
            allprice.value = '135000';
        }
    } 
    else if(membersheType === '3') {
        // 연간 50만원 구독권 사용자
        if (sizeValue === '상') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '350,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '500,000 원';
            titleElement.textContent = '로고 디자인 (상)';
            allprice.value = '350000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '210,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '300,000 원';
            titleElement.textContent = '로고 디자인 (중)';
            allprice.value = '210000';
        } else {
            discountPriceElement.style.display = 'block';
            discountPriceElement.textContent = '105,000 원';
            priceElement.style.textDecoration = 'line-through';
            priceElement.textContent = '150,000 원';
            titleElement.textContent = '로고 디자인 (하)'
            allprice.value = '105000';
        }
    }
    else if(membersheType === '0') {
        // 구독권 없는 사용자
        if (sizeValue === '상') {
            discountPriceElement.style.display = 'none';
            priceElement.textContent = '500,000 원';
            titleElement.textContent = '로고 디자인 (상)';
            allprice.value = '500000';
        } else if (sizeValue === '중') {
            discountPriceElement.style.display = 'none';
            priceElement.textContent = '300,000 원';
            titleElement.textContent = '로고 디자인 (중)';
            allprice.value = '300000';
        } else {
            discountPriceElement.style.display = 'none';
            priceElement.textContent = '150,000 원';
            titleElement.textContent = '로고 디자인 (하)';
            allprice.value = '150000';
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

// 프로젝트 사이즈 - 라디오 버튼 설정
const radios = document.querySelectorAll('input[name="size"]');
radios.forEach((radio) => {
    radio.addEventListener('click', async function() {
        const membersheType = await getSubscribeType();
        var sizeValue = this.value;
        console.log(`membership type : ${membersheType}`);
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
            const response = await fetch('/user/commission-project-logo', {
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

