CREATE TABLE HangSX (

 MaHangSX VARCHAR2(10) CONSTRAINT pk_hangsx PRIMARY KEY,

 TenHang VARCHAR2(30) NOT NULL,

 DiaChi VARCHAR2(50),

 SoDT VARCHAR2(15),



 Email VARCHAR2(50)

);

CREATE TABLE SanPham (

 MaSP VARCHAR2(10) CONSTRAINT pk_sanpham PRIMARY KEY,

 MaHangSX VARCHAR2(10) REFERENCES HangSX(MaHangSX),

 TenSP VARCHAR2(50) NOT NULL,

 SoLuong NUMBER(10),

 MauSac VARCHAR2(20),

 GiaBan NUMBER(15,2),

 DonViTinh VARCHAR2(15),

 MoTa CLOB

);

CREATE TABLE NhanVien (

 MaNV VARCHAR2(10) CONSTRAINT pk_nhanvien PRIMARY KEY,

 TenNV VARCHAR2(50) NOT NULL,

 GioiTinh VARCHAR2(10),

 DiaChi VARCHAR2(100),

 SoDT VARCHAR2(15),

 Email VARCHAR2(50),

 TenPhong VARCHAR2(30)

);

CREATE TABLE PNhap (

 SoHDN VARCHAR2(10) CONSTRAINT pk_pnhap PRIMARY KEY,

 NgayNhap DATE,

 MaNV VARCHAR2(10) REFERENCES NhanVien(MaNV)

);

CREATE TABLE Nhap (

 SoHDN VARCHAR2(10) REFERENCES PNhap(SoHDN),

 MaSP VARCHAR2(10) REFERENCES SanPham(MaSP),

 SoLuongN NUMBER(10),

 DonGiaN NUMBER(15,2),

 CONSTRAINT pk_nhap PRIMARY KEY (SoHDN, MaSP)

);

CREATE TABLE PXuat (

 SoHDX VARCHAR2(10) CONSTRAINT pk_pxuat PRIMARY KEY,

 NgayXuat DATE,

 MaNV VARCHAR2(10) REFERENCES NhanVien(MaNV)

);

CREATE TABLE Xuat (

 SoHDX VARCHAR2(10) REFERENCES PXuat(SoHDX),

 MaSP VARCHAR2(10) REFERENCES SanPham(MaSP),

 SoLuongX NUMBER(10),

 CONSTRAINT pk_xuat PRIMARY KEY (SoHDX, MaSP)

);







--1.1
create or replace procedure sp_NhapHangSX (
    p_mahangsx in varchar2,
    p_tenhang in varchar2,
    p_diachi in varchar2,
    p_sodt in VARCHAR2,
    p_email in varchar2
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from HANGSX h where h.TENHANG = p_tenhang;
    if v_dem > 0 then 
        dbms_output.put_line('Ten hang ' || p_tenhang || ' da ton tai');
    else 
        insert into HANGSX(MAHANGSX, TENHANG, DIACHI, SODT,EMAIL) VALUES (p_mahangsx, p_tenhang, p_diachi, p_sodt, p_email);
    end if;
end; 
/

--1.2
create or replace procedure sp_NhapSP (
    p_masp in varchar2,
    p_tenhang in varchar2,
    p_tensp in varchar2,
    p_soluong in number,
    p_mausac in varchar2,
    p_giaban in number,
    p_donvitinh in varchar2,
    p_mota in varchar2
) as 
v_demhang number := 0;
v_demsp number := 0;
v_mahangsx varchar2(10);
begin
    select count(*) into v_demhang from HANGSX h where h.TENHANG = p_tenhang;
    if v_demhang = 0 then 
        dbms_output.put_line('Ten hang ' || p_tenhang || ' khong co trong bang HangSX');
    else 
        select MAHANGSX into v_mahangsx from HANGSX where TENHANG = p_tenhang;
        select count(*) into v_demsp from SANPHAM s where s.MASP = p_masp;
        
        if v_demsp > 0 then
            update SANPHAM set MAHANGSX = v_mahangsx, TENSP = p_tensp, SOLUONG = p_soluong, MAUSAC = p_mausac, GIABAN = p_giaban, DONVITINH = p_donvitinh, MOTA = p_mota where MASP = p_masp;
        else
            insert into SANPHAM(MASP, MAHANGSX, TENSP, SOLUONG, MAUSAC, GIABAN, DONVITINH, MOTA) VALUES (p_masp, v_mahangsx, p_tensp, p_soluong, p_mausac, p_giaban, p_donvitinh, p_mota);
        end if;
    end if;
end;
/

--1.3
create or replace procedure sp_xoaHangSX (
    p_tenhang in varchar2
) as 
v_dem number := 0;
v_mahangsx varchar2(10);
begin
    select count(*) into v_dem from HANGSX h where h.TENHANG = p_tenhang;
    if v_dem = 0 then 
        dbms_output.put_line('Ten hang ' || p_tenhang || ' chua co');
    else 
        select MAHANGSX into v_mahangsx from HANGSX where TENHANG = p_tenhang;
        delete from SANPHAM where MAHANGSX = v_mahangsx;
        delete from HANGSX where MAHANGSX = v_mahangsx;
    end if;
end;
/

--1.4
create or replace procedure sp_NhapNhanVien (
    p_manv in varchar2,
    p_tennv in varchar2,
    p_gioitinh in varchar2,
    p_diachi in varchar2,
    p_sodt in varchar2,
    p_email in varchar2,
    p_tenphong in varchar2,
    p_flag in number
) as 
begin
    if p_flag = 0 then 
        update NHANVIEN set TENNV = p_tennv, GIOITINH = p_gioitinh, DIACHI = p_diachi, SODT = p_sodt, EMAIL = p_email, TENPHONG = p_tenphong where MANV = p_manv;
    else 
        insert into NHANVIEN(MANV, TENNV, GIOITINH, DIACHI, SODT, EMAIL, TENPHONG) VALUES (p_manv, p_tennv, p_gioitinh, p_diachi, p_sodt, p_email, p_tenphong);
    end if;
end;
/

--1.5
create or replace procedure sp_NhapBieuNhap (
    p_sohdn in varchar2,
    p_masp in varchar2,
    p_manv in varchar2,
    p_ngaynhap in date,
    p_soluongn in number,
    p_dongian in number
) as 
v_demsp number := 0;
v_demnv number := 0;
v_demhdn number := 0;
begin
    select count(*) into v_demsp from SANPHAM s where s.MASP = p_masp;
    if v_demsp = 0 then 
        dbms_output.put_line('Ma san pham ' || p_masp || ' khong co trong bang SanPham');
        return;
    end if;
    
    select count(*) into v_demnv from NHANVIEN nv where nv.MANV = p_manv;
    if v_demnv = 0 then 
        dbms_output.put_line('Ma nhan vien ' || p_manv || ' khong co trong bang NhanVien');
        return;
    end if;

    select count(*) into v_demhdn from PNHAP p where p.SOHDN = p_sohdn;
    if v_demhdn > 0 then 
        update NHAP set SOLUONGN = p_soluongn, DONGIAN = p_dongian where SOHDN = p_sohdn and MASP = p_masp;
    else 
        insert into PNHAP(SOHDN, NGAYNHAP, MANV) VALUES (p_sohdn, p_ngaynhap, p_manv);
        insert into NHAP(SOHDN, MASP, SOLUONGN, DONGIAN) VALUES (p_sohdn, p_masp, p_soluongn, p_dongian);
    end if;
end;
/

--1.6
create or replace procedure sp_NhapBieuXuat (
    p_sohdx in varchar2,
    p_masp in varchar2,
    p_manv in varchar2,
    p_ngayxuat in date,
    p_soluongx in number
) as 
v_demsp number := 0;
v_demnv number := 0;
v_demhdx number := 0;
v_soluongkho number := 0;
begin
    select count(*) into v_demsp from SANPHAM s where s.MASP = p_masp;
    if v_demsp = 0 then 
        dbms_output.put_line('Ma san pham ' || p_masp || ' khong co trong bang SanPham');
        return;
    end if;
    
    select count(*) into v_demnv from NHANVIEN nv where nv.MANV = p_manv;
    if v_demnv = 0 then 
        dbms_output.put_line('Ma nhan vien ' || p_manv || ' khong co trong bang NhanVien');
        return;
    end if;

    select SOLUONG into v_soluongkho from SANPHAM where MASP = p_masp;
    if p_soluongx > v_soluongkho then
        dbms_output.put_line('So luong xuat ' || p_soluongx || ' lon hon so luong ton kho (' || v_soluongkho || ')');
        return;
    end if;

    select count(*) into v_demhdx from PXUAT p where p.SOHDX = p_sohdx;
    if v_demhdx > 0 then 
        update XUAT set SOLUONGX = p_soluongx where SOHDX = p_sohdx and MASP = p_masp;
    else 
        insert into PXUAT(SOHDX, NGAYXUAT, MANV) VALUES (p_sohdx, p_ngayxuat, p_manv);
        insert into XUAT(SOHDX, MASP, SOLUONGX) VALUES (p_sohdx, p_masp, p_soluongx);
    end if;
end;
/

--1.7
create or replace procedure sp_XoaNhanVien (
    p_manv in varchar2
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from NHANVIEN nv where nv.MANV = p_manv;
    if v_dem = 0 then 
        dbms_output.put_line('Ma nhan vien ' || p_manv || ' chua co');
    else 
        delete from NHAP where SOHDN in (select SOHDN from PNHAP where MANV = p_manv);
        delete from XUAT where SOHDX in (select SOHDX from PXUAT where MANV = p_manv);
        delete from PNHAP where MANV = p_manv;
        delete from PXUAT where MANV = p_manv;
        delete from NHANVIEN where MANV = p_manv;
    end if;
end;
/

--1.8
create or replace procedure sp_XoaSanPham (
    p_masp in varchar2
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from SANPHAM s where s.MASP = p_masp;
    if v_dem = 0 then 
        dbms_output.put_line('Ma san pham ' || p_masp || ' chua co');
    else 
        delete from NHAP where MASP = p_masp;
        delete from XUAT where MASP = p_masp;
        delete from SANPHAM where MASP = p_masp;
    end if;
end;
/

--2.1
create or replace procedure sp_ThemNhanVien2 (
    p_manv in varchar2,
    p_tennv in varchar2,
    p_gioitinh in varchar2,
    p_diachi in varchar2,
    p_sodt in varchar2,
    p_email in varchar2,
    p_tenphong in varchar2,
    p_flag in number,
    p_kq out number
) as 
begin
    if p_gioitinh not in ('Nam', 'Nữ') then 
        p_kq := 1;
        return;
    end if;

    if p_flag = 0 then 
        insert into NHANVIEN(MANV, TENNV, GIOITINH, DIACHI, SODT, EMAIL, TENPHONG) VALUES (p_manv, p_tennv, p_gioitinh, p_diachi, p_sodt, p_email, p_tenphong);
        p_kq := 0;
    else 
        update NHANVIEN set TENNV = p_tennv, GIOITINH = p_gioitinh, DIACHI = p_diachi, SODT = p_sodt, EMAIL = p_email, TENPHONG = p_tenphong where MANV = p_manv;
        p_kq := 0;
    end if;
end;
/

--2.2
create or replace procedure sp_ThemMoiSP2 (
    p_masp in varchar2,
    p_tenhang in varchar2,
    p_tensp in varchar2,
    p_soluong in number,
    p_mausac in varchar2,
    p_giaban in number,
    p_donvitinh in varchar2,
    p_mota in varchar2,
    p_flag in number,
    p_kq out number
) as 
v_demhang number := 0;
v_mahangsx varchar2(10);
begin
    select count(*) into v_demhang from HANGSX h where h.TENHANG = p_tenhang;
    if v_demhang = 0 then 
        p_kq := 1;
        return;
    end if;
    
    if p_soluong < 0 then
        p_kq := 2;
        return;
    end if;

    select MAHANGSX into v_mahangsx from HANGSX where TENHANG = p_tenhang;

    if p_flag = 0 then 
        insert into SANPHAM(MASP, MAHANGSX, TENSP, SOLUONG, MAUSAC, GIABAN, DONVITINH, MOTA) VALUES (p_masp, v_mahangsx, p_tensp, p_soluong, p_mausac, p_giaban, p_donvitinh, p_mota);
        p_kq := 0;
    else 
        update SANPHAM set MAHANGSX = v_mahangsx, TENSP = p_tensp, SOLUONG = p_soluong, MAUSAC = p_mausac, GIABAN = p_giaban, DONVITINH = p_donvitinh, MOTA = p_mota where MASP = p_masp;
        p_kq := 0;
    end if;
end;
/

--2.3
create or replace procedure sp_XoaNhanVien2 (
    p_manv in varchar2,
    p_kq out number
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from NHANVIEN nv where nv.MANV = p_manv;
    if v_dem = 0 then 
        p_kq := 1;
    else 
        delete from NHAP where SOHDN in (select SOHDN from PNHAP where MANV = p_manv);
        delete from XUAT where SOHDX in (select SOHDX from PXUAT where MANV = p_manv);
        delete from PNHAP where MANV = p_manv;
        delete from PXUAT where MANV = p_manv;
        delete from NHANVIEN where MANV = p_manv;
        p_kq := 0;
    end if;
end;
/

--2.4
create or replace procedure sp_XoaSanPham2 (
    p_masp in varchar2,
    p_kq out number
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from SANPHAM s where s.MASP = p_masp;
    if v_dem = 0 then 
        p_kq := 1;
    else 
        delete from NHAP where MASP = p_masp;
        delete from XUAT where MASP = p_masp;
        delete from SANPHAM where MASP = p_masp;
        p_kq := 0;
    end if;
end;
/

--2.5
create or replace procedure sp_NhapHangSX2 (
    p_mahangsx in varchar2,
    p_tenhang in varchar2,
    p_diachi in varchar2,
    p_sodt in varchar2,
    p_email in varchar2,
    p_kq out number
) as 
v_dem number := 0;
begin
    select count(*) into v_dem from HANGSX h where h.TENHANG = p_tenhang;
    if v_dem > 0 then 
        p_kq := 1;
    else 
        insert into HANGSX(MAHANGSX, TENHANG, DIACHI, SODT, EMAIL) VALUES (p_mahangsx, p_tenhang, p_diachi, p_sodt, p_email);
        p_kq := 0;
    end if;
end;
/

--2.6
create or replace procedure sp_NhapBieuNhap2 (
    p_sohdn in varchar2,
    p_masp in varchar2,
    p_manv in varchar2,
    p_ngaynhap in date,
    p_soluongn in number,
    p_dongian in number,
    p_kq out number
) as 
v_demsp number := 0;
v_demnv number := 0;
v_demhdn number := 0;
begin
    select count(*) into v_demsp from SANPHAM s where s.MASP = p_masp;
    if v_demsp = 0 then 
        p_kq := 1;
        return;
    end if;
    
    select count(*) into v_demnv from NHANVIEN nv where nv.MANV = p_manv;
    if v_demnv = 0 then 
        p_kq := 2;
        return;
    end if;

    select count(*) into v_demhdn from PNHAP p where p.SOHDN = p_sohdn;
    if v_demhdn > 0 then 
        update NHAP set SOLUONGN = p_soluongn, DONGIAN = p_dongian where SOHDN = p_sohdn and MASP = p_masp;
        p_kq := 0;
    else 
        insert into PNHAP(SOHDN, NGAYNHAP, MANV) VALUES (p_sohdn, p_ngaynhap, p_manv);
        insert into NHAP(SOHDN, MASP, SOLUONGN, DONGIAN) VALUES (p_sohdn, p_masp, p_soluongn, p_dongian);
        p_kq := 0;
    end if;
end;
/

--2.7
create or replace procedure sp_NhapBieuXuat2 (
    p_sohdx in varchar2,
    p_masp in varchar2,
    p_manv in varchar2,
    p_ngayxuat in date,
    p_soluongx in number,
    p_kq out number
) as 
v_demsp number := 0;
v_demnv number := 0;
v_demhdx number := 0;
v_soluongkho number := 0;
begin
    select count(*) into v_demsp from SANPHAM s where s.MASP = p_masp;
    if v_demsp = 0 then 
        p_kq := 1;
        return;
    end if;
    
    select count(*) into v_demnv from NHANVIEN nv where nv.MANV = p_manv;
    if v_demnv = 0 then 
        p_kq := 2;
        return;
    end if;

    select SOLUONG into v_soluongkho from SANPHAM where MASP = p_masp;
    if p_soluongx > v_soluongkho then
        p_kq := 3;
        return;
    end if;

    select count(*) into v_demhdx from PXUAT p where p.SOHDX = p_sohdx;
    if v_demhdx > 0 then 
        update XUAT set SOLUONGX = p_soluongx where SOHDX = p_sohdx and MASP = p_masp;
        p_kq := 0;
    else 
        insert into PXUAT(SOHDX, NGAYXUAT, MANV) VALUES (p_sohdx, p_ngayxuat, p_manv);
        insert into XUAT(SOHDX, MASP, SOLUONGX) VALUES (p_sohdx, p_masp, p_soluongx);
        p_kq := 0;
    end if;
end;
/




set serveroutput on;
--test 1.1
begin
    sp_NhapHangSX('H01', 'Samsung', 'Han Quoc', '0123456789', 'ss@gmail.com');
end;
/

--test 1.2
begin
    sp_NhapSP('SP01', 'Samsung', 'Galaxy S23', 100, 'Den', 20000000, 'Chiec', 'Dien thoai cao cap');
end;
/

--test 1.3
begin
    sp_xoaHangSX('Samsung');
end;
/

--test 1.4
begin
    sp_NhapNhanVien('NV01', 'Nguyen Van A', 'Nam', 'Ha Noi', '0987654321', 'a@gmail.com', 'Kinh Doanh', 1);
end;
/

--test 1.5
begin
    sp_NhapBieuNhap('HDN01', 'SP01', 'NV01', TO_DATE('2023-10-10', 'YYYY-MM-DD'), 50, 15000000);
end;
/

--test 1.6
begin
    sp_NhapBieuXuat('HDX01', 'SP01', 'NV01', TO_DATE('2023-10-11', 'YYYY-MM-DD'), 10);
end;
/

--test 1.7
begin
    sp_XoaNhanVien('NV01');
end;
/

--test 1.8
begin
    sp_XoaSanPham('SP01');
end;
/

--test 2.1
declare
v_kq number;
begin
    sp_ThemNhanVien2('NV02', 'Tran Thi B', 'Nữ', 'HCM', '0912345678', 'b@gmail.com', 'Ke Toan', 0, v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.2
declare
v_kq number;
begin
    sp_ThemMoiSP2('SP02', 'Samsung', 'Galaxy A54', 50, 'Trang', 10000000, 'Chiec', 'Dien thoai tam trung', 0, v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.3
declare
v_kq number;
begin
    sp_XoaNhanVien2('NV02', v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.4
declare
v_kq number;
begin
    sp_XoaSanPham2('SP02', v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.5
declare
v_kq number;
begin
    sp_NhapHangSX2('H02', 'Apple', 'My', '0111222333', 'apple@gmail.com', v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.6
declare
v_kq number;
begin
    sp_NhapBieuNhap2('HDN02', 'SP02', 'NV02', TO_DATE('2023-10-10', 'YYYY-MM-DD'), 20, 8000000, v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/

--test 2.7
declare
v_kq number;
begin
    sp_NhapBieuXuat2('HDX02', 'SP02', 'NV02', TO_DATE('2023-10-11', 'YYYY-MM-DD'), 5, v_kq);
    dbms_output.put_line('Ket qua: ' || v_kq);
end;
/