import { Html5QrcodeScanner } from "html5-qrcode"

let activeScanner = null;

// Bersihkan scanner sebelum navigasi halaman
window.addEventListener("phx:page-loading-start", () => {
  if (activeScanner) {
    activeScanner.clear().catch(() => {});
    activeScanner = null;
  }
});

export const QrScanner = {
  mounted() {
    this.scanner = new Html5QrcodeScanner(
      "qr-reader",
      { 
        fps: 10, 
        qrbox: {width: 250, height: 250},
        useBarCodeDetectorIfSupported: true
      },
      false
    )
    
    activeScanner = this.scanner;

    // Gunakan observer untuk mengubah teks error bawaan html5-qrcode
    this.observer = new MutationObserver((mutations) => {
      // html5-qrcode bisa merender error di berbagai elemen di dalam container
      const errorEls = this.el.querySelectorAll("span, div");
      errorEls.forEach(el => {
        // Gunakan replace pada innerHTML agar tidak menghilangkan tag <a> (link) di dalamnya
        if (el.innerHTML && el.innerHTML.includes("NotReadableError")) {
          el.innerHTML = el.innerHTML.replace(/NotReadableError[^<]*/g, "Kamera sedang digunakan oleh aplikasi lain. Tutup aplikasi tersebut lalu muat ulang halaman.");
        }
        if (el.innerHTML && el.innerHTML.includes("NotFoundException")) {
          el.innerHTML = el.innerHTML.replace(/NotFoundException[^<]*/g, "QR Code tidak ditemukan pada gambar tersebut.");
        }
      });
    });
    this.observer.observe(this.el, { childList: true, subtree: true });

    let isProcessing = false;
    const onScanSuccess = (decodedText, decodedResult) => {
      if (isProcessing) return;
      isProcessing = true;
      
      const fallback = setTimeout(() => { isProcessing = false; }, 5000);
      
      this.pushEvent("scan_success", { token: decodedText }, (reply, ref) => {
        clearTimeout(fallback);
        setTimeout(() => {
          isProcessing = false;
        }, 2000);
      });
    }

    const onScanFailure = (error) => {
    }

    this.scanner.render(onScanSuccess, onScanFailure)
  },

  destroyed() {
    if (this.observer) this.observer.disconnect();
    if (this.scanner) {
      this.scanner.clear().catch(error => {})
      if (activeScanner === this.scanner) activeScanner = null;
    }
  }
}

export default {
    QrScanner
}
