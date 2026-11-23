###Tugas 7

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





###Tugas 8
1. Jelaskan perbedaan antara Navigator.push(), Navigator.pushReplacement(), dan Navigator.pop(). Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Jelaskan juga bagaimana opsi Home di drawer membawa pengguna kembali ke halaman utama.

`Navigator.push()`: Menumpuk halaman baru di atas halaman lama (bisa kembali dengan tombol Back)
`Navigator.pushReplacement()`: Mengganti halaman lama dengan halaman baru (halaman lama dihapus, tidak bisa kembali)
`Navigator.pop()`: Menutup halaman saat ini dan kembali ke halaman sebelumnya

untuk buka formulir dari kartu aksi menggunakan Navigator.push() agar pengguna bisa kembali ke halaman utama jika batal mengisi formulir

Opsi Home di Drawer menggunakan Navigator.pushReplacement() untuk mengganti halaman aktif dengan halaman utama agar halaman tidak menumpuk (atau cukup Navigator.pop() jika sudah di halaman utama)

2. Bagaimana susunan Scaffold, AppBar, dan Drawer membantu menjaga struktur halaman tetap konsisten? Berikan satu contoh penggunaan warna tema portofolio di lebih dari satu halaman.

`Scaffold` menjadi kerangka dasar halaman yang seragam, `AppBar` menjaga tampilan judul dan tombol atas selalu konsisten, sedangkan `Drawer` menyediakan menu samping yang sama di setiap halaman

Contohnya, warna indigo dipakai pada AppBar halaman Home dan halaman Add Project. Di halaman Home, warna itu menjadi latar AppBar bertuliskan “MyPortfolio”, sedangkan di halaman Add Project menjadi latar AppBar bertuliskan “Add Project Form” intinya agar tampilannya tetap selaras

3. Mengapa tata letak tersebut dipilih untuk formulir? Jelaskan peran widget pengatur jarak dan widget penggulir ketika ruang layar terbatas.

tata letak vertikal karna Layar HP berbentuk memanjang ke bawah, sehingga susunan ke bawah membuat kolom input lebih lebar, mudah dibaca, dan nyaman disentuh

peran pengatur jarak & penggulir itu ketika layar sempit (misalnya tertutup keyboard), pengatur jarak (Padding/SizedBox) mencegah kolom saling menempel, sedangkan penggulir (SingleChildScrollView) memungkinkan layar digeser ke atas/bawah agar form tidak terpotong atau error (overflow)


4. Apa peran GlobalKey<FormState>, validator, dan validate() saat tombol Simpan ditekan? Berikan satu contoh nilai yang ditolak oleh validasi dan jelaskan mengapa memilih jenis input atau papan ketik saja belum cukup.

peran GlobalKey<FormState> menjadi penghubung antara tombol Simpan dan form. Saat tombol ditekan, validate() menjalankan semua fungsi validator di tiap kolom untuk mengecek apakah isian sudah benar baru setelah uti data dapat disimpan

contoh nya adalah angka -500 pada kolom harga atau teks kosong/spasi. menggunakan (TextInputType.number) saja tidak cukup karena belum tentu bisa mecegah input kosong, input angka minus/nol, ataupun teks huruf yang dicopy-paste

saya menggunakan ai untuk membantu memahami checklist tugas memahami alur penggunaan scaffold appbar dan drawer, membantu implementasi dengan menghubungkan navigasi dari halaman utama dan drawer, serta memperbaiki pengujian dan evaluasi akhir keseluruhan dengan meminta bantuan untuk mengecek hasilnya
