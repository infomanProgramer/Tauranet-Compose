export function renderFrameComanda(){
    console.log("Imprimiendo comanda desde utils/printcomandas.js...");
    // Crear o mostrar el contenedor del PDF
    let pdfContainer = document.getElementById('pdfPreviewContainer');
    if (!pdfContainer) {
        pdfContainer = document.createElement('div');
        pdfContainer.id = 'pdfPreviewContainer';
        pdfContainer.style.position = 'fixed';
        pdfContainer.style.top = '0';
        pdfContainer.style.left = '0';
        pdfContainer.style.width = '100%';
        pdfContainer.style.height = '100%';
        //pdfContainer.style.height = 'auto';
        pdfContainer.style.backgroundColor = 'rgba(0,0,0,0.8)';
        pdfContainer.style.zIndex = '9999';
        pdfContainer.style.display = 'flex';
        pdfContainer.style.justifyContent = 'center';
        pdfContainer.style.alignItems = 'center';
        
        // Crear iframe para mostrar el PDF
        const iframe = document.createElement('iframe');
        iframe.id = 'pdfIframe';
        iframe.style.width = '80%';
        iframe.style.height = '90%';
        //iframe.style.height = 'auto';
        iframe.style.border = 'none';
        iframe.style.borderRadius = '8px';
        iframe.style.backgroundColor = '#fff';
        
        // Botón para cerrar
        const closeBtn = document.createElement('button');
        closeBtn.innerHTML = '&times;';
        closeBtn.style.position = 'absolute';
        closeBtn.style.top = '20px';
        closeBtn.style.right = '20px';
        closeBtn.style.background = '#ff4444';
        closeBtn.style.color = 'white';
        closeBtn.style.border = 'none';
        closeBtn.style.borderRadius = '50%';
        closeBtn.style.width = '40px';
        closeBtn.style.height = '40px';
        closeBtn.style.fontSize = '20px';
        closeBtn.style.cursor = 'pointer';
        closeBtn.onclick = function() {
            document.body.removeChild(pdfContainer);
        };
        
        // Botón para imprimir
        const printBtn = document.createElement('button');
        printBtn.innerHTML = 'Imprimir';
        printBtn.style.position = 'absolute';
        printBtn.style.bottom = '20px';
        printBtn.style.left = '50%';
        printBtn.style.transform = 'translateX(-50%)';
        printBtn.style.padding = '10px 20px';
        printBtn.style.background = '#4CAF50';
        printBtn.style.color = 'white';
        printBtn.style.border = 'none';
        printBtn.style.borderRadius = '4px';
        printBtn.style.cursor = 'pointer';
        printBtn.onclick = function() {
            iframe.contentWindow.print();
        };
        
        pdfContainer.appendChild(closeBtn);
        pdfContainer.appendChild(printBtn);
        pdfContainer.appendChild(iframe);
        document.body.appendChild(pdfContainer);
    } else {
        // Si el contenedor ya existe, mostrarlo
        pdfContainer.style.display = 'flex';
    }
}

export function listOfProductsToString(listOfProducts){
    let listOfProductsString = "";
    let i = 0;
    listOfProducts.forEach(element => {
        if(i == listOfProducts.length-1){
            listOfProductsString = listOfProductsString+element.id_producto+"|"+element.cantidad+"|"+element.p_unit+"|"+element.importe+"|"+element.nota+"|"+element.p_base+"|"+element.importe_base+"|"+element.detalle
        }else{
            listOfProductsString = listOfProductsString+element.id_producto+"|"+element.cantidad+"|"+element.p_unit+"|"+element.importe+"|"+element.nota+"|"+element.p_base+"|"+element.importe_base+"|"+element.detalle+":" 
        }
        i++
    });
    return listOfProductsString;
}