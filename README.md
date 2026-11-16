Tugas 7

1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak bekerja antar-widget!

widget tree itu susunan widget yang membentuk tampilan aplikasi, jadi widget bisa membungkus widget lain lewat `child` atau `children`. misalnya di project ini Scaffold menjadi induk dari AppBar dan bagian body, lalu di dalam body ada susunan kartu. induk memberikan batas ukuran ke anak, anak menentukan ukurannya sesuai batas tersebut, kemudian induk mengatur posisinya.

2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!

- `MyApp`: widget awal yang menyiapkan aplikasi.
- `MaterialApp`: mengatur tema dan halaman utama.
- `MyHomePage`: menyusun halaman menu portofolio.
- `Scaffold` dan `AppBar`: kerangka halaman dan bagian judul di atas.
- `SingleChildScrollView`: membuat halaman bisa digulir kalau isinya melebihi layar.
- `Center` dan `ConstrainedBox`: menengahkan konten dan membatasi lebarnya.
- `LayoutBuilder`: membaca ruang yang tersedia untuk menentukan jumlah kolom.
- `Column` dan `Wrap`: menyusun widget ke bawah dan memindah kartu ke baris berikutnya kalau ruangnya kurang.
- `SizedBox` dan `Padding`: mengatur ukuran, jarak antar-widget dan ruang di sekitar konten.
- `GridView.count`: menyusun tombol dalam grid dengan jumlah kolom yang ditentukan.
- `InfoCard` dan `Card`: komponen identitas dan tampilan kartu yang membungkusnya.
- `ItemCard`: komponen tombol aksi portofolio.
- `Material` dan `InkWell`: memberi latar tombol serta menangani tap dengan efek sentuhan.
- `Text` dan `Icon`: menampilkan tulisan dan ikon.
- `SnackBar`: menampilkan pesan sementara setelah tombol ditekan.
- `MediaQuery`: diakses untuk membaca skala teks sistem, juga dipakai pada test untuk mencoba teks yang diperbesar.

`ScaffoldMessenger.of` dipakai untuk menampilkan SnackBar. sementara ItemHomepage itu model data nama, ikon dan warna tombol, jadi bukan widget.

3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!

MaterialApp menyiapkan kebutuhan aplikasi Material seperti tema, navigasi dan halaman awal. karena pengaturannya membungkus halaman lain, widget di bawahnya bisa memakai tema dan fasilitas yang sama tanpa disiapkan satu persatu

4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih masing-masing?

StatelessWidget ga punya object State untuk menyimpan perubahan internal, cocok untuk tampilan yang bergantung pada data dari luar seperti InfoCard dan menu sekarang intinya dia tetap bisa dibangun ulang kalau induknya memberikan data baru. StatefulWidget punya State yang bertahan saat widget dibangun ulang, cocok kalau ada counter, pilihan filter atau data yang berubah selama halaman dipakai, biasanya tampilannya diperbarui lewat pake setState.

5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?

BuildContext itu penanda posisi widget di dalam tree, jadi Flutter bisa mencari induk atau pengaturan yang berlaku dari posisi tersebut. di dalam build aku pakai Theme.of untuk mengambil warna tema dan MediaQuery.textScalerOf untuk membaca skala teks. saat tombol ditekan, context juga dipakai lewat ScaffoldMessenger.of untuk menampilkan SnackBar.

6. Jelaskan konsep hot reload di Flutter dan perbedaannya dengan hot restart! Kapan harus menggunakan hot restart atau full restart?

hot reload memasukkan perubahan kode lalu membangun ulang tampilan sambil mempertahankan State, jadi enak buat mengubah warna atau layout. hot restart menjalankan ulang aplikasi Dart sehingga State direset dan `main` serta `initState` dijalankan lagi, ini diperlukan kalau perubahan inisialisasi ga terlihat lewat hot reload, misalnya nilai awal pada variabel global atau static.

kalau yang diubah kode native Android/iOS atau konfigurasi plugin native, perlu full restart dengan menghentikan aplikasi lalu menjalankannya lagi supaya bagian native ikut dibangun ulang.

AI Disclosure

menggunakan ai untuk membantu evaluasi checklist tugas, memahami alur implementasi serta pemahaman tentang flatter, dan juga membantu menganalisis struktur aplikasi sesuai dengan ketentuan tugas