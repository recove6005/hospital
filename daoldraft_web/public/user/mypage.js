var subscribeType = '';
var pjtIndex = 0;

async function initializePage() {
    try {
        // 로딩 인디케이터 표시
        document.body.style.opacity = '0.5';
        document.body.style.pointerEvents = 'none';

        await checkLogin();
        await getSubscribeInfos();
        await checkUserAdminAndDisplay();
        await initProjectInfo();
        await initPaymentInfo();

        // 모든 데이터 로딩이 완료되면 페이지 표시
        document.body.style.opacity = '1';
        document.body.style.pointerEvents = 'auto';
    } catch(e) {
        console.error('페이지 초기화 중 오류 발생:', error);
        // 에러 발생 시 사용자에게 알림
        Swal.fire('오류', '데이터를 불러오는 중 문제가 발생했습니다.', 'error');
    }

}

initializePage();

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

        // 관리자 계정 체크
        const response = await fetch('/login/check-admin', {
            method: 'POST',
            credentials: 'include',
        });

        if(response.ok) {
            document.getElementById('dropdown-management').style.display = 'flex';
        }

    } else {
        document.getElementById("to-signin").style.display = 'block';
    }
}

async function getUserInitData() {
    // 구독권 타입
    const response = await fetch('/user/get-subscribe-type', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        subscribeType = result.subscribe;
    } else {
        console.log(`error : ${result.error}`);
    }
}

// 구독 정보 적용
async function getSubscribeInfos() {
    await getUserInitData();

    const subscribeWrapper = document.querySelector('.subscribe-details-wrapper');
    if(subscribeType == '0') {
        // 구독권 없음
        subscribeWrapper.innerHTML = `<p>구독 내역이 없습니다.</p>`;
    } else {
        // 구독권이 있음
        const response = await fetch('/user/get-subscribe-info', {
            method: 'POST',
        });
    
        const result = await response.json();
        if(response.ok) {
            subscribeWrapper.innerHTML = `
                <p>
                    -- 구독 정보 --
                </p>
            `;
        } else {
            console.log(`error: ${result.error}`);
        }
    }
}

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
    window.location.href = "login-email.html";
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

// 비밀번호 변경
document.getElementById('update-password').addEventListener('click', async (e) =>  {
    Swal.fire({
        title: '비밀번호 재설정',
        text: '비밀번호를 변경하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소',
    }).then(async (result) => {
        if(result.isConfirmed) {
            try {
                const updateResponse = await fetch('/login/update-password', {
                    method: 'POST',
                    credentials: "include",
                });
                
                if(updateResponse.ok) {
                    Swal.fire('성공', '비밀번호 변경 링크가 전송되었습니다. 이메일을 확인해 주세요.', 'success');
                } else {
                    const errorData = await response.json();
                    console.log(`Error: ${errorData.error}`);
                    Swal.fire('오류', '비밀번호 변경 요청 중 문제가 발생했습니다.', 'error');
                }
            } catch (error) {
                console.error('Request failed:', error);
                Swal.fire('오류', '서버와 통신 중 문제가 발생했습니다.', 'error');
            }
        }
    }); 
});


// 프로젝트 리스트
const userProjects = [];
let pagedProjects = [];

// 프로젝트 리스트 가져오기
async function getProjects() {
    const response = await fetch('/project/get-projects-by-uid', {
        method: 'POST',
    });

    const result = await response.json();
    if(response.ok) {
        result.forEach((pjt) => {
            userProjects.push(pjt);
        });
    } else {
        console.log(`error: ${result.error}`);
    }
}

// 프로젝트 가격 가져오기
async function getPrice(docId) {
    const response = await fetch('/project/get-price', {
        method: 'POST',
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({
            docId: docId,
        }),
    });

    const result = await response.json();
    if(response.ok) {
        return result.price;
    } else {
        return '---';
    }
}

// 프로젝트 내역: 페이저 인덱스 버튼 innterText 설정
let page = 0;
async function setProjectIndexes() {    
    for(let i = 0; i < 5; i++) {
        const index = document.getElementById(`project-index-${i}`);
        index.innerText = `${page+i+1}`;
    }     
}

// 페이저 인덱스 버튼 클릭 이벤트 리스너
let isDisplayed = false;
async function setProjectIndexEventListener() {
    pagedProjects = [];
    for(let i = 0; i < 5; i++) {
        const indexBtn = document.getElementById(`project-index-${i}`);
        
        indexBtn.addEventListener('click', async (e) => {
            e.preventDefault();
    
            if(isDisplayed) return;
            isDisplayed = true;
            const listwrapper = document.querySelector('.project-list ul');
            listwrapper.innerHTML = ``;
            pagedProjects = [];
            
            indexBtn.innerText = `${page+i+1}`;
            const eventIndexStart = (parseInt(indexBtn.innerText, 10)-1)*5;

            for(let l = eventIndexStart; l < eventIndexStart+5; l++) {
                if(userProjects[l]) {
                    pagedProjects.push(userProjects[l]);
                } 
                else break;
            }

            await displayProjectList();
            isDisplayed = false;
        }); 
    }
}

// 프로젝트 내역: 페이저 버튼 이벤트 리스너
document.getElementById('project-pager-prev-btn').addEventListener('click', (e) => {
    e.preventDefault();
    if(page != 0) page -= 5;
    setProjectIndexes();
});

document.getElementById('project-pager-next-btn').addEventListener('click', (e) => {
    e.preventDefault();
    page += 5;
    setProjectIndexes();
});

// 프로젝트 내역 표시
async function displayProjectList() {
    const projectList = document.querySelector('.project-list ul');
    const emptyCount = 5 - pagedProjects.length;

    for (let pjt of pagedProjects) {    
        // 문의 일자
        const date = new Date(pjt.date);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const formattedDate = `${year}-${month}-${day}`;

        // 가격
        const price = await getPrice(pjt.docId);

        // 프로젝트ID
        const docId = pjt.docId;

        // 프로젝트 진행 현황
        let progress = '문의 접수';
        if(pjt.progress == '1') progress = '작업 중';
        if(pjt.progress == '2' || pjt.progress == '11') progress = '결제 중';
        if(pjt.progress == '3') progress = '결제 완료';

        const itemLi = document.createElement('li');
        const itemA = document.createElement('a');
        itemA.classList.add('project-list-item');
        itemA.innerHTML = `
            <p class="item-detail">${pjt.title}</p>
            <p class="item-detail">${progress}</p>
            <p class="item-detail">${formattedDate}</p>
            <p class="item-detail">${price}</p>
        `;

        itemA.addEventListener("click", () => {
            window.location.href = `../user/project-info.html?docId=${docId}`;    
        });
        
        itemLi.appendChild(itemA);
        projectList.appendChild(itemLi);
    };

    for(let i = 0; i < emptyCount; i++) {
        const itemLi = document.createElement('li');
        const itemA = document.createElement('a');
        itemA.classList.add('project-list-item');
        itemA.innerHTML = `
            <p class="item-detail">-</p>
            <p class="item-detail">-</p>
            <p class="item-detail">-</p>
            <p class="item-detail">-</p>
        `;

        itemLi.appendChild(itemA);
        projectList.appendChild(itemLi);
    }
}


// 결제 내역 가져오기
let priceList = [];
let pagedPrices = [];
let paymentPage = 0;
async function getPayedPrices() {
    const response = await fetch('/project/get-payed-prices', {
        method: 'POST',
        credentials: "include",
    });

    const result = await response.json();
    if(response.ok) {
        priceList = result.priceList;
    } else {
        console.log(result.error);
    }
}

// 결제 내역: 페이저 버튼 이벤트 리스너
document.getElementById('payment-pager-prev-btn').addEventListener('click', (e) => {
    e.preventDefault();
    if(paymentPage != 0) paymentPage -= 5;
    setPaymentIndexes();
});

document.getElementById('payment-pager-next-btn').addEventListener('click', (e) => {
    e.preventDefault();
    paymentPage += 5;
    setPaymentIndexes();
});

// 결제내역 표시
async function displayPaymentList() {
    const paymentUl = document.querySelector('.payment-details-wrapper ul');
    paymentUl.innerHTML = ``;
    let emptyCount = 5 - pagedPrices.length;

    for(let i = 0; i < pagedPrices.length; i++) {
        const newLi = document.createElement('li');
        const fd = new Date(priceList[i].date);
        const newDate = `${fd.getFullYear()}-${String(fd.getMonth()+1).padStart(2,'0')}-${String(fd.getDate()).padStart(2, '0')}`;
        newLi.innerHTML = `
                <div class="payment-detail-item">
                    <p class="payment-detail-category">${priceList[i].title}</p>
                    <p class="payment-detail-category">${priceList[i].paytype}</p>
                    <p class="payment-detail-category">${newDate}</p>
                    <p class="payment-detail-category">${priceList[i].price}</p>
                </div>  
        `;
        paymentUl.appendChild(newLi);
    }

    for(let i = 0; i < emptyCount; i++) {
        const itemLi = document.createElement('li');
        itemLi.classList.add('payment-list-item');
        itemLi.innerHTML = `
            <div class="payment-detail-item">
                <p class="payment-detail-category">-</p>
                <p class="payment-detail-category">-</p>
                <p class="payment-detail-category">-</p>
                <p class="payment-detail-category">-</p>
            </div>  
        `;
        paymentUl.appendChild(itemLi);
    }
}


// 결제내역 페이징
async function setPaymentIndexes() {
    for(let i = 0; i < 5; i++) {
        const index = document.getElementById(`payment-index-${i}`);
        index.innerText = `${paymentPage+i+1}`;
    }     
}

async function setPaymentIndexEventListener() {
    pagedPrices = [];

    for(let i = 0; i < 5; i++) {
        const indexBtn = document.getElementById(`payment-index-${i}`);
        
        indexBtn.addEventListener('click', async (e) => {
            e.preventDefault();
    
            const listwrapper = document.querySelector('.payment-details-wrapper ul');
            pagedPrices = [];
    
            indexBtn.innerText = `${paymentPage+i+1}`;
            const eventIndexStart = (parseInt(indexBtn.innerText, 10)-1)*5;

            for(let l = eventIndexStart; l < eventIndexStart+5; l++) {
                if(priceList[l]) {
                    pagedPrices.push(priceList[l]);
                } 
                else break;
            }

            listwrapper.innerHTML = ``;
            displayPaymentList();
        }); 
    }
}

// 프로젝트 내역 초기 UI 업데이트 함수
async function initProjectInfo() {
    // 전체 프로젝트 내역 초기화
    await getProjects();

    // 프로젝트 내역 페이징
    await setProjectIndexes();
    await setProjectIndexEventListener();

    document.getElementById('project-index-0').click();    
}

async function initPaymentInfo() {
    // 결제내역 페이징
    await getPayedPrices();

    await setPaymentIndexes();
    await setPaymentIndexEventListener();

    document.getElementById('payment-index-0').click();
}

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