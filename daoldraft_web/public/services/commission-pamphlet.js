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

        window.location.href="../intro/home.html";
    } catch(e) {
        console.error("Unexpected error during logout:", error);
        alert("An unexpected error occurred. Please try again.");
    }
});

// 상품 메뉴 스와이프
const swipeNextBtn = document.getElementById('swipe-next-btn');
const swipePrevBtn = document.getElementById('swipe-prev-btn');
swipeNextBtn.addEventListener('click', (e) => {
    const navlist = document.querySelectorAll('#project-nav ul li');
    navlist.forEach(li => {
        li.style.transform = `translateX(-555px)`;
    });

    swipeNextBtn.style.display = 'none';
    swipePrevBtn.style.display = 'block';
});

swipePrevBtn.addEventListener('click', (e) => {
    const navlist = document.querySelectorAll('#project-nav ul li');
    navlist.forEach(li => {
        li.style.transform = `translateX(0px)`;
    });

    swipeNextBtn.style.display = 'block';
    swipePrevBtn.style.display = 'none';
});

// 디스플레이 자동 슬라이드
const displayBox = document.querySelector('.display-box');
const displayBox0 = document.getElementById('display-box-0');
const displayBox1 = document.getElementById('display-box-1');
const displaySwipePrevBtn = document.getElementById('display-swipe-prev-btn');
const displaySwipeNextBtn = document.getElementById('display-swipe-next-btn');
const displayPagenation = document.getElementById('pagenation');

let currentIndex = 0;
let position = 0;
const totalSlides = 2;
const totalClones = 2;

function setupClones() {
    const clone0 = displayBox.children[0].cloneNode(true); // 첫 번째 슬라이드 복제
    const clone1 = displayBox.children[1].cloneNode(true); // 두 번째 슬라이드 복제
    
    displayBox.appendChild(clone0);
    displayBox.appendChild(clone1);
}

function lastSetupClones() {
    const slides = Array.from(displayBox.children);
    const clone0 = slides[slides.length - 2].cloneNode(true); // 첫 번째 슬라이드 복제
    const clone1 = slides[slides.length - 1].cloneNode(true); // 두 번째 슬라이드 복제

    displayBox.prepend(clone1);
    displayBox.prepend(clone0);
}

function mod(n, m) {
    return ((n % m) + m) % m;
}

function updateSlide(index) {
    const slides = Array.from(displayBox.children);

    // 위치 계산
    position = index * -410;

    slides.forEach((slide, i) => {
        slide.style.transform = `translateX(${position}px)`;
        slide.style.transition = 'transform 0.5s ease';
    });

    // 페이지네이션 업데이트
    const modValue = mod(index, 2); // 총 슬라이드의 반복 처리
    if (modValue === 0) displayPagenation.innerText = ` 1 / 2 `;
    else displayPagenation.innerText = ` 2 / 2 `;
}

function slidePrev() {
    const slides = Array.from(displayBox.children);

    // 첫 번째 슬라이드로 이동 시 처리
    if (currentIndex === 0) {
        currentIndex = slides.length - 2; // 마지막 슬라이드로 이동
        position = currentIndex * -410;

        slides.forEach((slide) => {
            slide.style.transition = 'none'; // 애니메이션 제거
            slide.style.transform = `translateX(${position}px)`;
        });

        setTimeout(() => {
            slidePrev(); // 다시 호출하여 부드럽게 이동
        }, 50);
    } else {
        currentIndex--; // 이전 슬라이드로 이동
        updateSlide(currentIndex);
    }
}

function slideNext() {
    const slides = Array.from(displayBox.children);

    // 마지막 슬라이드로 이동 시 처리
    if (currentIndex === slides.length - 2) {
        currentIndex = 0; // 첫 번째 슬라이드로 이동
        position = currentIndex * -410;

        slides.forEach((slide) => {
            slide.style.transition = 'none'; // 애니메이션 제거
            slide.style.transform = `translateX(${position}px)`;
        });

        setTimeout(() => {
            slideNext(); // 다시 호출하여 부드럽게 이동
        }, 50);
    } else {
        currentIndex++; // 다음 슬라이드로 이동
        updateSlide(currentIndex);
    }
}

// 이전 버튼 이벤트
displaySwipePrevBtn.addEventListener('click', (e) => {
    e.preventDefault();
    slidePrev();
});

// 다음 버튼 이벤트
displaySwipeNextBtn.addEventListener('click', (e) => {
    e.preventDefault();
    slideNext();
});

// 초기화
setupClones();
lastSetupClones();
updateSlide(currentIndex);

// 자동 슬라이드 실행 (5초 간격)
let autoSlideInterval = setInterval(slideNext, 5000);

// 마우스 이벤트로 자동 슬라이드 제어
const displayWrapper = document.getElementById('contact-display-wrapper');
displayWrapper.addEventListener('mouseenter', () => clearInterval(autoSlideInterval));
displayWrapper.addEventListener('mouseleave', () => autoSlideInterval = setInterval(slideNext, 5000));

// 연락처 input 문자열
document.getElementById('call').addEventListener("input", (e) => {
    let input = e.target.value;

    // 숫자만 남기기
    input = input.replace(/[^0-9]/g, "");

    if(input.length > 11) {
        input = input.slice(0,11);
    }

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
            const response = await fetch('/user/commission-project', {
                method: 'POST',
                credentials: "include",
                headers: { "Content-Type" : "application/json "},
                body: JSON.stringify(formValues),
            });            
            const result = await response.json();
            
            if(response.status == 200) {
                alert('프로젝트가 접수됐습니다. 마이페이지에서 확인해 주세요.');
                window.location.href = '../intro/home.html';
            } else {
                console.log(result.error);
            }
    
        } catch(e) {
            console.error("error: ", e);
        }
    } else {
        window.location.href = '../user/login-email.html';
    }
});

document.getElementById('swipe-next-btn').click();