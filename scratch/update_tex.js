const fs = require('fs');

const newTex = `\\section{Implementasi \\textit{Indexing}}

\\subsection{Deskripsi}

\\textit{Indexing} adalah mekanisme struktur data tambahan yang memungkinkan MySQL menemukan baris yang relevan tanpa membaca seluruh isi tabel. Index bertipe BTREE menyimpan salinan kolom dalam bentuk terurut sehingga pencarian dapat dilakukan dalam kompleksitas $O(\\log n)$ alih-alih $O(n)$.

Strategi \\textit{indexing} pada CineTrack didasarkan pada frekuensi pemakaian kolom di seluruh komponen sistem: 5 \\textit{query case}, 3 \\textit{function}, 3 \\textit{stored procedure}, dan 3 \\textit{trigger}.

\\begin{longtable}{|c|p{4.0cm}|p{2.8cm}|p{2.5cm}|p{3.2cm}|}
\\caption{Daftar \\textit{Index} pada Basis Data CineTrack}
\\label{tab:daftar_index} \\\\
\\hline
\\textbf{No} & \\textbf{Nama \\textit{Index}} & \\textbf{Tabel} & \\textbf{Kolom} & \\textbf{Digunakan Oleh} \\\\
\\hline
\\endfirsthead
\\hline
\\textbf{No} & \\textbf{Nama \\textit{Index}} & \\textbf{Tabel} & \\textbf{Kolom} & \\textbf{Digunakan Oleh} \\\\
\\hline
\\endhead
\\hline
\\endlastfoot
1 & \\texttt{\\seqsplit{idx\\_film\\_status\\_tayang}} & \\texttt{film} & \\texttt{status\\_tayang} & Query Kasus 1 \\\\
\\hline
2 & \\texttt{\\seqsplit{idx\\_jtf\\_film}} & \\texttt{\\seqsplit{jadwal\\_tayang\\_film}} & \\texttt{film\\_id\\_film} & \\textit{Function} 3, Query Kasus 2 \\\\
\\hline
3 & \\texttt{\\seqsplit{idx\\_transaksi\\_total\\_tagihan}} & \\texttt{\\seqsplit{transaksi}} & \\texttt{total\\_tagihan} & Query Kasus 3 \\\\
\\hline
4 & \\texttt{\\seqsplit{idx\\_tiket\\_jadwal\\_kursi}} & \\texttt{tiket} & \\texttt{\\seqsplit{jadwal\\_tayang\\_id\\_jadwal, kursi\\_id\\_kursi}} & Trigger 1 (Pencegahan Double-Booking) \\\\
\\hline
5 & \\texttt{\\seqsplit{idx\\_pelanggan\\_email}} & \\texttt{pelanggan} & \\texttt{\\seqsplit{email\\_pelanggan}} & Auth Login, Google Auth, Signup \\\\
\\hline
\\end{longtable}

\\subsection{\\textit{Index} 1: \\texttt{idx\\_film\\_status\\_tayang}}

\\textbf{Fungsi:} Query Kasus 1 memfilter tabel \\texttt{film} dengan kondisi \\texttt{WHERE status\\_tayang = 'Now Showing'} untuk keperluan tim promosi. Kolom \\texttt{status\\_tayang} bukan bagian dari \\textit{primary key} maupun \\textit{foreign key}, sehingga tanpa index MySQL melakukan \\textit{full table scan}. Index pada kolom ini memungkinkan MySQL langsung menunjuk baris yang relevan.

\\begin{lstlisting}[style=sql, caption={\\textit{Index} 1 --- \\texttt{idx\\_film\\_status\\_tayang}}, label={lst:idx1}]
CREATE INDEX idx_film_status_tayang
    ON film (status_tayang);

EXPLAIN
SELECT f.judul, f.status_tayang, g.nama_genre
FROM film f
JOIN film_genre fg ON f.id_film         = fg.film_id_film
JOIN genre      g  ON fg.genre_id_genre = g.id_genre
WHERE f.status_tayang = 'Now Showing'
ORDER BY f.judul, g.nama_genre;
\\end{lstlisting}

\\begin{figure}[H]
    \\centering
    \\includegraphics[width=1\\linewidth]{index/output_idx1.png}
    \\caption{Hasil \\texttt{EXPLAIN} \\textit{Index} 1}
    \\label{fig:idx1}
\\end{figure}

\\subsection{\\textit{Index} 2: \\texttt{idx\\_jtf\\_film}}

\\textbf{Fungsi:} \\textit{Primary key} tabel \\textit{junction} \\texttt{\\seqsplit{jadwal\\_tayang\\_film}} adalah \\textit{composite} (\\texttt{\\seqsplit{jadwal\\_tayang\\_id\\_jadwal}}, \\texttt{film\\_id\\_film}). Index BTREE pada PK \\textit{composite} hanya efisien untuk \\textit{lookup} yang dimulai dari kolom \\textbf{pertama} (jadwal). Kolom kedua (\\texttt{film\\_id\\_film}) tidak ter-\\textit{cover} sebagai \\textit{leading key}, sehingga \\textit{reverse lookup}, yang digunakan oleh \\textit{Function} \\texttt{GetDurasiTayang} dan Query Kasus 2, tetap melakukan \\textit{full scan} tanpa index ini.

\\begin{lstlisting}[style=sql, caption={\\textit{Index} 2 --- \\texttt{idx\\_jtf\\_film}}, label={lst:idx2}]
CREATE INDEX idx_jtf_film
    ON jadwal_tayang_film (film_id_film);

EXPLAIN
SELECT jt.id_jadwal, jt.waktu_tayang, f.judul, f.durasi
FROM jadwal_tayang      jt
JOIN jadwal_tayang_film jtf ON jt.id_jadwal     = jtf.jadwal_tayang_id_jadwal
JOIN film               f   ON jtf.film_id_film = f.id_film
ORDER BY jt.waktu_tayang;
\\end{lstlisting}

\\begin{figure}[H]
    \\centering
    \\includegraphics[width=1\\linewidth]{index/output_idx2.png}
    \\caption{Hasil \\texttt{EXPLAIN} \\textit{Index} 2}
    \\label{fig:idx2}
\\end{figure}

\\subsection{\\textit{Index} 3: \\texttt{idx\\_transaksi\\_total\\_tagihan}}

\\textbf{Fungsi:} Query Kasus 3 memfilter tabel \\texttt{transaksi} dengan kondisi \\texttt{WHERE total\\_tagihan > 200000} untuk analisis transaksi bernilai tinggi. Kolom \\texttt{total\\_tagihan} bertipe \\texttt{DECIMAL} dan tidak memiliki index apapun. Index pada kolom numerik menyimpan nilai secara terurut sehingga MySQL dapat langsung melompat ke nilai \\textit{threshold} tanpa men-\\textit{scan} seluruh tabel.

\\begin{lstlisting}[style=sql, caption={\\textit{Index} 3 --- \\texttt{idx\\_transaksi\\_total\\_tagihan}}, label={lst:idx3}]
CREATE INDEX idx_transaksi_total_tagihan
    ON transaksi (total_tagihan);

EXPLAIN
SELECT tx.id_transaksi, pl.nama_pelanggan,
       tx.total_tagihan, pb.metode_pembayaran
FROM transaksi  tx
JOIN pelanggan  pl ON tx.pelanggan_id_pelanggan   = pl.id_pelanggan
JOIN pembayaran pb ON tx.pembayaran_id_pembayaran = pb.id_pembayaran
WHERE tx.total_tagihan > 200000
ORDER BY tx.total_tagihan DESC;
\\end{lstlisting}

\\begin{figure}[H]
    \\centering
    \\includegraphics[width=1\\linewidth]{index/output_idx3.png}
    \\caption{Hasil \\texttt{EXPLAIN} \\textit{Index} 3}
    \\label{fig:idx3}
\\end{figure}

\\subsection{\\textit{Index} 4: \\texttt{idx\\_tiket\\_jadwal\\_kursi}}

\\textbf{Fungsi:} Menghindari \\textit{full table scan} pada saat \\textit{trigger} \\texttt{trg\\_cegah\\_double\\_booking} melakukan pengecekan ketersediaan kursi dan jadwal tayang sebelum proses pemesanan tiket baru disimpan ke basis data.

\\begin{lstlisting}[style=sql, caption={\\textit{Index} 4 --- \\texttt{idx\\_tiket\\_jadwal\\_kursi}}, label={lst:idx4}]
CREATE INDEX idx_tiket_jadwal_kursi
    ON tiket (jadwal_tayang_id_jadwal, kursi_id_kursi);

EXPLAIN
SELECT COUNT(*) AS kursi_terisi
FROM tiket
WHERE jadwal_tayang_id_jadwal = 'JD0001'
  AND kursi_id_kursi          = 'KR0001';
\\end{lstlisting}

\\begin{figure}[H]
    \\centering
    \\includegraphics[width=1\\linewidth]{index/output_index4.png}
    \\caption{Hasil \\texttt{EXPLAIN} \\textit{Index} 4}
    \\label{fig:idx4}
\\end{figure}

\\subsection{\\textit{Index} 5: \\texttt{idx\\_pelanggan\\_email}}

\\textbf{Fungsi:} Mempercepat pencarian email pelanggan saat proses autentikasi login lokal, login Google Auth, dan verifikasi keunikan pendaftaran akun baru pada web CineTrack. Indeks bertipe \\texttt{UNIQUE} ini mengubah kompleksitas pencarian menjadi sangat efisien (\\texttt{const}).

\\begin{lstlisting}[style=sql, caption={\\textit{Index} 5 --- \\texttt{idx\\_pelanggan\\_email}}, label={lst:idx5}]
CREATE UNIQUE INDEX idx_pelanggan_email
    ON pelanggan (email_pelanggan);
    
EXPLAIN
SELECT id_pelanggan, nama_pelanggan, email_pelanggan
FROM pelanggan
WHERE email_pelanggan = 'pelanggan1@gmail.com';
\\end{lstlisting}

\\begin{figure}[H]
    \\centering
    \\includegraphics[width=1\\linewidth]{index/output_idx5.png}
    \\caption{Hasil \\texttt{EXPLAIN} \\textit{Index} 5}
    \\label{fig:idx5}
\\end{figure}`;

const texFile = 'lapres_mbd/main.tex';
let content = fs.readFileSync(texFile, 'utf8');

const regex = /\\section\{Implementasi \\textit\{Indexing\}\}[\s\S]*?\\label\{fig:idx5\}\r?\n\\end\{figure\}/;
if (regex.test(content)) {
    content = content.replace(regex, newTex);
    fs.writeFileSync(texFile, content, 'utf8');
    console.log("Updated main.tex successfully.");
} else {
    console.log("Regex did not match.");
}
