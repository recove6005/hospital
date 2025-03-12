document.addEventListener('DOMContentLoaded', async () => {
    
});

document.getElementById('search-btn').addEventListener('click', async () => {
    const orderId = document.getElementById('order-id').value.trim();
    const email = document.getElementById('email').value.trim();

    if(orderId === '' || email === '') {
        alert('주문번호와 이메일을 입력해주세요.');
        return;
    }

    const refResponse = await fetch('/api/order/store-order-ref', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ order_id: orderId, email: email })
    });


    if(refResponse.redirected) {
        window.location.href = refResponse.url;
    } else {
        const refResult = await refResponse.json();
        alert(refResult.error);
    }
});