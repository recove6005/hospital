document.addEventListener('DOMContentLoaded', () => {
    const nav = document.getElementById('nav');
    
    // 대분류 메뉴 호버 이벤트
    nav.addEventListener('mouseover', (e) => {
        const majorItem = e.target.closest('.major > li');
        if (majorItem) {
            // 모든 메뉴 숨기기
            hideAllMenus();
            
            // 현재 중분류 메뉴 보이기
            const middleMenu = majorItem.querySelector('.middle');
            if (middleMenu) {
                showMenu(middleMenu);
            }
        }
    });

    // 중분류 메뉴 호버 이벤트
    nav.addEventListener('mouseover', (e) => {
        const middleItem = e.target.closest('.middle > li');
        if (middleItem) {
            // 다른 소분류 메뉴 숨기기
            const currentMiddle = middleItem.closest('.middle');
            currentMiddle.querySelectorAll('.minor').forEach(menu => {
                hideMenu(menu);
            });
            
            // 현재 소분류 메뉴 보이기
            const minorMenu = middleItem.querySelector('.minor');
            if (minorMenu) {
                showMenu(minorMenu);
            }
        }
    });

    // 네비게이션 영역 마우스 이탈 시
    nav.addEventListener('mouseleave', () => {
        hideAllMenus();
    });
});

function showMenu(menu) {
    menu.style.display = 'block';
    // 강제 리플로우를 통해 트랜지션 적용
    menu.offsetHeight;
    menu.classList.add('show');
}

function hideMenu(menu) {
    menu.classList.remove('show');
    menu.style.display = 'none';
}

function hideAllMenus() {
    document.querySelectorAll('.middle, .minor').forEach(menu => {
        hideMenu(menu);
    });
}