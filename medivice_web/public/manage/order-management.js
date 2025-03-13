import { prodNameExchange } from '../constants.js';
var orders = [];
var selectedOrders = [];

document.addEventListener('DOMContentLoaded', async () => {
    const key = window.location.search.split('=')[1];
    const keyCheckResponse = await fetch('/api/entry/store-query-key', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ key: key }),
    });

    if(keyCheckResponse.ok) {
        // 초기 진입 시 전체 데이터 표시
        const getOrdersResponse = await fetch('/api/order/store-get-all-orders');
        if(getOrdersResponse.ok) {
            const ulElement = document.getElementById('entry-success-list');
            orders = await getOrdersResponse.json();

            if(orders.length === 0) {
                ulElement.innerHTML = `<p id='search-result-empty'>요청된 주문이 없습니다.</p>`;
                return;
            }

            orders.forEach(order => {
                const orderDate = order.order_date.substring(0, 10);
                const liElement = document.createElement('li');
                liElement.innerHTML = `
                    <div class="list-row">
                        <div class='list-select'>
                            <input type='checkbox' id='order-checkbox' value='${order.order_id}'>
                        </div>
                        <p class='list-date'>${orderDate}</p>
                        <div class="order-content">
                            <p>
                            ${order.products.map((product) => {
                                return `
                                    ${prodNameExchange(product.prodName)} / ${product.standard} / ${product.quantity}개 <br>
                                `;
                            })}
                            </p>
                        </div>
                        <p class='list-price'>${order.price}</p>
                        <p class='list-hosp'>${order.hospital_name}</p>
                        <p class='list-tel'>${order.call}</p>
                        <p class='list-email'>${order.email}</p>
                    </div>
                `;  
                ulElement.appendChild(liElement);
            });
        }
    } else {
        console.log(keyCheckResponse.status);
    }
});

function isDateBeforeToday(date) {
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    const inputDate = new Date(date);
    return inputDate <= today;
}

function isStartDateBeforeEndDate(startDate, endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);
    return start <= end;
}

// 전체 선택
document.getElementById('select-all-input').addEventListener('click', () => {
    const orderCheckboxes = document.querySelectorAll('#order-checkbox');
    for(const checkbox of orderCheckboxes) {
        checkbox.checked = document.getElementById('select-all-input').checked;
    }
});

// 주문 검색 - 기간별
document.getElementById('search-btn').addEventListener('click', async () => {
    const startDate = document.getElementById('search-start-date').value;
    const endDate = document.getElementById('search-end-date').value;

    if(startDate === '' || endDate === '') {
        alert('날짜를 선택해주세요.');
        return;
    }

    if(!isDateBeforeToday(startDate) || !isDateBeforeToday(endDate)) {
        alert('오늘 이전 날짜를 선택해주세요.');
        return;
    }

    if(!isStartDateBeforeEndDate(startDate, endDate)) {
        alert('시작 날짜가 종료 날짜보다 이전이어야 합니다.');
        return;
    }

    const searchResponse = await fetch('/api/order/store-get-scoped-orders', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            startDate: startDate,
            endDate: endDate
        }),
    });

    if(searchResponse.ok) {
        const ulElement = document.getElementById('entry-success-list');
        ulElement.innerHTML = '';

        orders = await searchResponse.json();
        console.log(orders);

        orders.forEach(order => {
            const orderDate = order.order_date.substring(0, 10);
            const liElement = document.createElement('li');
            liElement.innerHTML = `
                <div class='list-tile' id="check-tile">
                <input type='checkbox' id='order-checkbox' value='${order.order_id}'>
                </div>
                <p class='list-tile'>${orderDate}</p>
                <p class='list-tile'>${order.product_name}</p>
                <p class='list-tile'>${order.quantity}</p>
                <p class='list-tile'>${order.standard}</p>
                <p class='list-tile'>${order.hospital_name}</p>
                <p class='list-tile'>${order.call_num}</p>
                <p class='list-tile'>${order.email}</p>
            `;
            ulElement.appendChild(liElement);
        });
    } else {
        const ulElement = document.getElementById('entry-success-list');
        ulElement.innerHTML = `<p id='search-result-empty'>요청된 주문이 없습니다.</p>`;
        const searchResult = await searchResponse.json();
        console.log(searchResult.error);
    }
});

// 엑셀
document.getElementById('download-btn').addEventListener('click', async () => {
    const orderCheckboxes = document.querySelectorAll('#order-checkbox');
    for(const checkbox of orderCheckboxes) {
        if(checkbox.checked) {
            selectedOrders.push(orders.find(order => order.order_id === checkbox.value));
        }
    }

    const workbook = XLSX.utils.book_new();
    const datas = selectedOrders.map(order => { 
        return {
            '주문일자': order.order_date.substring(0, 10),
            '주문 내용': order.products.map(product => `${prodNameExchange(product.prodName)} ${product.standard} ${product.quantity}개`).join(' / \n'),
            '합계': order.price,
            '병원명': order.hospital_name,
            '연락처': order.call,
            '이메일': order.email,
        }
    });
    const worksheet = XLSX.utils.json_to_sheet(datas);
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Orders');
    XLSX.writeFile(workbook, 'order-list.xlsx');
});

// 주문 삭제 - mysql
document.getElementById('delete-btn').addEventListener('click', async () => {
    const orderCheckboxes = document.querySelectorAll('#order-checkbox');
    const ids = [];

    for(const checkbox of orderCheckboxes) {
        if(checkbox.checked) {
            ids.push({order_id: checkbox.value});
        }
    }

    if(ids.length === 0) {
        alert('삭제할 주문을 선택해주세요.');
        return;
    } else {
        const deleteResponse = await fetch('/api/order/db-delete-orders', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(ids),
        });

        if(deleteResponse.ok) {
            alert('주문이 삭제되었습니다.');
            window.location.reload();
        } else {
            const deleteResult = await deleteResponse.json();
            console.log(deleteResult.error);
        }
    }
});

// 주문 삭제 - firestore
document.getElementById('delete-btn').addEventListener('click', async () => {
    const orderCheckboxes = document.querySelectorAll('#order-checkbox');
    const ids = [];

    for(const checkbox of orderCheckboxes) {
        if(checkbox.checked) {
            ids.push({order_id: checkbox.value});
        }
    }

    if(ids.length === 0) {
        alert('삭제할 주문을 선택해주세요.');
        return;
    } else {
        const deleteResponse = await fetch('/api/order/store-delete-orders', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(ids),
        });

        if(deleteResponse.ok) {
            alert('주문이 삭제되었습니다.');
            window.location.reload();
        } else {
            const deleteResult = await deleteResponse.json();
            console.log(deleteResult.error);
        }
    }
});

