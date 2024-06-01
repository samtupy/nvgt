import ftplib, os, sys
from pathlib import Path

def get_version_info():
	return Path("../version").read_text().strip().replace("-", "_")

ftp_creds=sys.argv[1].split(":")
ver = get_version_info()
if ftp_creds:
	try:
		ftp = ftplib.FTP("nvgt.gg", ftp_creds[0], ftp_creds[1])
		f = open(f"nvgt_{ver}.exe", "rb")
		ftp.storbinary(f"STOR nvgt_{ver}.exe", f)
		f.close()
		ftp.quit()
	except Exception as e:
		print(f"Warning, cannot upload to ftp {e}")
