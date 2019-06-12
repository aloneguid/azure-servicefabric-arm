param
(
    [Parameter(Mandatory=$True)]
    [string] $RemotePath = "",

    [Parameter(Mandatory=$True)]
    [string] $LocalPath
)

function getTimestamp
{
    return $(Get-Date).ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss.fff")
}

cmd /C rmdir $LocalPath
if ($LASTEXITCODE -ne 0)
{
    Write-Host "$(getTimestamp) - Failed to deleted symbolic link $LocalPath to $RemotePath. Error $($LASTEXITCODE)."
    exit 1
}
else
{
    Write-Host "$(getTimestamp) - Deleted symbolic link $LocalPath to $RemotePath"
}

try
{
    if ($RemotePath -ne "")
    {
        Remove-SmbGlobalMapping -RemotePath $RemotePath -Force -ErrorAction Stop
        Write-Host "$(getTimestamp) - Unmapped $RemotePath"
    }
}
catch
{
    Write-Host "$(getTimestamp) - Failed to unmap $RemotePath. $($_.Exception)"
    exit 1
}
# SIG # Begin signature block
# MIIdmwYJKoZIhvcNAQcCoIIdjDCCHYgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUok++rzR42ExfLj1+bMu5Mmjs
# AaGgghhfMIIE2jCCA8KgAwIBAgITMwAAAQxsIwULB5kezQAAAAABDDANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTgwODIzMjAyMDM0
# WhcNMTkxMTIzMjAyMDM0WjCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# LTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046RkM0MS00QkQ0LUQyMjAxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCO1S+QNIfQl05MvK2qCZdUhp26KrBTVZ0lBY2yrlJJ+lkn
# vd50+oHQESUNwXcgaDzNDv//ILA+M+trKzggkctne7QQyWdhDReiG7ys8yARz3M9
# kX1SUKRa3QGUJgiQjwEtyCRYRZKQVkMs6khlobG+q75X5cQRnJV3mjyD21TomVIz
# RoyMv3fgVZ7VDkfM1TLGgnrcuMAqIGKzLnHHdRJ38lzQCacr59g4zPASDN5Mo9vU
# T3Y3wsr8HfNgDaqAHQI0mJtVDKY+FOPY9FQx/zyip+vyJ3GpMdrmPbIaGgaoHLXo
# 4wF97qpxok6lrypxThw7O2DLXB74xiL+9uxHkllzAgMBAAGjggEJMIIBBTAdBgNV
# HQ4EFgQUle1s3XXPM7bDhbeMFjQIDBsoKhcwHwYDVR0jBBgwFoAUIzT42VJGcArt
# QPt2+7MrsMM1sw8wVAYDVR0fBE0wSzBJoEegRYZDaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNy
# bDBYBggrBgEFBQcBAQRMMEowSAYIKwYBBQUHMAKGPGh0dHA6Ly93d3cubWljcm9z
# b2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0VGltZVN0YW1wUENBLmNydDATBgNV
# HSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQUFAAOCAQEAWPj0bJs6vOs/3ln2
# GbbeXV893lKIG+Cpy24LYfH1J3sq7JO5l7nPM7wqWHBlQ9/nqbnoTGqOMv30bNMQ
# mFOuDuOwmua2xxcBNa/FtrGG9XJ3rUpk/oar6UpDfZFLBxZeO7ULI4jxZI+pITne
# YoPVMbkIVHEJB24feqHz9E0E5Ofc4HjfcMPUY/6Kum4OU0GDhBEazSDmAHrhuusV
# jrAKXXFZ6l8ZQ6ynD9ZKs8/uxOGkEFPm+xwgQtl4U0Nch6rg/ksVCjAQYi5MUNBa
# HHUZg8vkO9sYL2W5KjX1kdwMkSc7UqfcykIOf1UdeohJhGo30F+jFKf04pmBRs1x
# CnQB1DCCBfQwggPcoAMCAQICEzMAAAECm/ALp45dw00AAAAAAQIwDQYJKoZIhvcN
# AQELBQAwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYG
# A1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMTAeFw0xODA3MTIy
# MDA4NDhaFw0xOTA3MjYyMDA4NDhaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xHjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANQMBgSFCJYop+lrdNDiYZPjpTBf
# 9QjDW4T2wacw94hKh51p1Ph+8LLz89lGtOFkFf1vnsoWx1ioo5mM1af88Y0ad2Ds
# XUULx5tqUQmEA5LkEGqo+3I4DToEx7BWQS9MlKuwwMiiL5/R8wPZCQGlC6jdFaZe
# Yiihqq7b2tVEmqMJMtnFK9rsK20RjPXRHZpzcP+a+OilunSo6nZze9WW8Bi4J8zo
# 7ZRGEbhpl5X4mLNxmDHue9i7dbU5XyJkeQ1Z6qaEOPH6j2OXrFQXusmdP2UtN5fq
# fnAcmeXa4+puPtclHN8YBJ1r4EOEY28FSLG5XTwmaKwxyv1+7u7a22xGw1sCAwEA
# AaOCAXMwggFvMB8GA1UdJQQYMBYGCisGAQQBgjdMCAEGCCsGAQUFBwMDMB0GA1Ud
# DgQWBBSJFwWujTtn71whoV8lsN1JuTdO7zBFBgNVHREEPjA8pDowODEeMBwGA1UE
# CxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMRYwFAYDVQQFEw0yMzAwMTIrNDM3OTY0
# MB8GA1UdIwQYMBaAFEhuZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBH
# oEWGQ2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNp
# Z1BDQTIwMTFfMjAxMS0wNy0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUF
# BzAChkVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0Nv
# ZFNpZ1BDQTIwMTFfMjAxMS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAgEAk/YCcku0liV5Dhj7G7SYmGisI5nl62F8EeChIwDJfvNJKOB1
# /fNoxBnGoFZVaiK7NVUlG8FmcnOnYiK0QW6HMHosY6QmLX/5QLF4ecXD9XuNoefo
# QFZneTUEdmAmV402GZItm9ht0EFKxUzXHcd28nqzPyUTj43bK9dPFMnCZYqjG7nf
# 4sQYWAWs8e0MS+fkhH9EYstmopIqt8iRc0o8+4unKv/iYbQRWQHXi2uWIYatRm7b
# qplfsfBg6Oj4OSoSRlZ7WXt8DQL1nAIUthX8Z1v/siivkBGpOHz0RX8gH/Qrv1XJ
# LdVjU8DrF6Agi5gY5Vf1ApQyhBJvOlBv9daFEue3MwPBxUcw9oeP/H+JCmIZpRNI
# yw8+X5SAVlkws9PIdPogPc4xiG5asNzG5MivUwioKlk5unq6VD0wgz1BmW3Wz9jo
# sCWkPNSL5itVFHo+mpE5P4x+u1eElRAmQ8JmhNwrmSPMTU8l8dBAOUnvPy3RUbI+
# C70q1D2hb/VwqZ9rVZlBKWkSU6hL81PiyLZRN/1rvzvPrxfsgnhwoScAePRTs+HJ
# kUnmwLTPm9kxZVtAlwToOAGT4gnHK/v5vwh+ApOevIRAPEvCZfzu9TYUJTVrizEk
# QCVUA6RmR7PQI7aPF8mw72ByKIQk4KgINwrunNgHHoWLnM8Un6Hmku/VdYcwggYH
# MIID76ADAgECAgphFmg0AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJ
# k/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMT
# JE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMx
# MjUzMDlaFw0yMTA0MDMxMzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLj
# xZlRI1Ctzt0YTiQP7tGn0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP
# 9w4EmPCJzB/LMySHnfL0Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZs
# k2fXKNxGU7CG0OUoRi4nrIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPz
# CLdTbVK0RZCfSABKR2YRJylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQ
# MEbtt94jRrvELVSfrx54QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsC
# AwEAAaOCAaswggGnMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK
# 7UD7dvuzK7DDNbMPMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYD
# VR0jBIGQMIGNgBQOrIJgQFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT
# 8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMk
# TWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxz
# WPQHEy5lMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNv
# bS9wa2kvY3JsL3Byb2R1Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEF
# BQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2kvY2VydHMvTWljcm9zb2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUF
# BwMIMA0GCSqGSIb3DQEBBQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVtt
# DBOrzr57j7gu1BKijG1iuFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu
# 4r6PCgXIjUji8FMV3U+rkuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+Jw
# vBhOnY5rCnKVuKE5nGctxVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UK
# E9/CCmGO8Ne4F+tOi3/FNSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1
# PLlmWLMtL+f5hYbMUVbonXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvAL
# xyy7z0Oz5fnsfbXjpKh0NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCe
# FTBm6EISXhrIniIh0EPpK+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QG
# Ee52Ib+bgsEnVLaxaj2JoXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJk
# Aj0tr1mPuOQh5bWwymO0eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wl
# v6DvhMoh1useT8ma7kng9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8u
# VRZryROj/TCCB3owggVioAMCAQICCmEOkNIAAAAAAAMwDQYJKoZIhvcNAQELBQAw
# gYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
# KU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDExMB4XDTEx
# MDcwODIwNTkwOVoXDTI2MDcwODIxMDkwOVowfjELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmlu
# ZyBQQ0EgMjAxMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKvw+nIQ
# HC6t2G6qghBNNLrytlghn0IbKmvpWlCquAY4GgRJun/DDB7dN2vGEtgL8DjCmQaw
# yDnVARQxQtOJDXlkh36UYCRsr55JnOloXtLfm1OyCizDr9mpK656Ca/XllnKYBoF
# 6WZ26DJSJhIv56sIUM+zRLdd2MQuA3WraPPLbfM6XKEW9Ea64DhkrG5kNXimoGMP
# LdNAk/jj3gcN1Vx5pUkp5w2+oBN3vpQ97/vjK1oQH01WKKJ6cuASOrdJXtjt7UOR
# g9l7snuGG9k+sYxd6IlPhBryoS9Z5JA7La4zWMW3Pv4y07MDPbGyr5I4ftKdgCz1
# TlaRITUlwzluZH9TupwPrRkjhMv0ugOGjfdf8NBSv4yUh7zAIXQlXxgotswnKDgl
# mDlKNs98sZKuHCOnqWbsYR9q4ShJnV+I4iVd0yFLPlLEtVc/JAPw0XpbL9Uj43Bd
# D1FGd7P4AOG8rAKCX9vAFbO9G9RVS+c5oQ/pI0m8GLhEfEXkwcNyeuBy5yTfv0aZ
# xe/CHFfbg43sTUkwp6uO3+xbn6/83bBm4sGXgXvt1u1L50kppxMopqd9Z4DmimJ4
# X7IvhNdXnFy/dygo8e1twyiPLI9AN0/B4YVEicQJTMXUpUMvdJX3bvh4IFgsE11g
# lZo+TzOE2rCIF96eTvSWsLxGoGyY0uDWiIwLAgMBAAGjggHtMIIB6TAQBgkrBgEE
# AYI3FQEEAwIBADAdBgNVHQ4EFgQUSG5k5VAF04KqFzc3IrVtqMp1ApUwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAUci06AjGQQ7kUBU7h6qfHMdEjiTQwWgYDVR0fBFMwUTBP
# oE2gS4ZJaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNybDBeBggrBgEFBQcBAQRSMFAw
# TgYIKwYBBQUHMAKGQmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMv
# TWljUm9vQ2VyQXV0MjAxMV8yMDExXzAzXzIyLmNydDCBnwYDVR0gBIGXMIGUMIGR
# BgkrBgEEAYI3LgMwgYMwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvZG9jcy9wcmltYXJ5Y3BzLmh0bTBABggrBgEFBQcCAjA0HjIg
# HQBMAGUAZwBhAGwAXwBwAG8AbABpAGMAeQBfAHMAdABhAHQAZQBtAGUAbgB0AC4g
# HTANBgkqhkiG9w0BAQsFAAOCAgEAZ/KGpZjgVHkaLtPYdGcimwuWEeFjkplCln3S
# eQyQwWVfLiw++MNy0W2D/r4/6ArKO79HqaPzadtjvyI1pZddZYSQfYtGUFXYDJJ8
# 0hpLHPM8QotS0LD9a+M+By4pm+Y9G6XUtR13lDni6WTJRD14eiPzE32mkHSDjfTL
# JgJGKsKKELukqQUMm+1o+mgulaAqPyprWEljHwlpblqYluSD9MCP80Yr3vw70L01
# 724lruWvJ+3Q3fMOr5kol5hNDj0L8giJ1h/DMhji8MUtzluetEk5CsYKwsatruWy
# 2dsViFFFWDgycScaf7H0J/jeLDogaZiyWYlobm+nt3TDQAUGpgEqKD6CPxNNZgvA
# s0314Y9/HG8VfUWnduVAKmWjw11SYobDHWM2l4bf2vP48hahmifhzaWX0O5dY0Hj
# Wwechz4GdwbRBrF1HxS+YWG18NzGGwS+30HHDiju3mUv7Jf2oVyW2ADWoUa9WfOX
# pQlLSBCZgB/QACnFsZulP0V3HjXG0qKin3p6IvpIlR+r+0cjgPWe+L9rt0uX4ut1
# eBrs6jeZeRhL/9azI2h15q/6/IvrC4DqaTuv/DDtBEyO3991bWORPdGdVk5Pv4BX
# IqF4ETIheu9BCrE/+6jMpF3BoYibV3FWTkhFwELJm3ZbCoBIa/15n8G9bW1qyVJz
# Ew16UM0xggSmMIIEogIBATCBlTB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAy
# MDExAhMzAAABApvwC6eOXcNNAAAAAAECMAkGBSsOAwIaBQCggbowGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFK2wl2rAQLZ5W0sSvlgE8OfeMLjkMFoGCisGAQQBgjcC
# AQwxTDBKoCSAIgBNAGkAYwByAG8AcwBvAGYAdAAgAFcAaQBuAGQAbwB3AHOhIoAg
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3dpbmRvd3MwDQYJKoZIhvcNAQEBBQAE
# ggEAZHlA0Dy18EezH2D3F4QtrytbQzLGt58LIJjYGXHd3YGytRYjzOu3wj1rzfEJ
# 5HCEOD7fR2cii/ccnAVAxLNv/U4Ff2c42DWZYGTBTg5Q14Eg0DhI8828is6rlkGw
# IMWpUhebQQdihOpnwFcN0cLoaCvlMWMeK8X88d8e5Pe4dnbb2aDUW4i+7XtlIAH5
# DCgYHBSObyaRP1JIg1QAlKxim3aMWDqpY94UuxAtwOcrX/Z/BuRH7dRy6qSUz95n
# hy6fS6aJnT+foVrPTD4ZH1z8laGArwvTdq1C5XWG98mpY+mgpWm0igpZlcY9bnsV
# rDUBKHiS4FcTly6GrJhImqAPKaGCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIB
# ATCBjjB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYD
# VQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0ECEzMAAAEMbCMFCweZHs0AAAAA
# AQwwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZI
# hvcNAQkFMQ8XDTE4MTAxODExMDk1NFowIwYJKoZIhvcNAQkEMRYEFPw40FvCR3C2
# ckSqHXdna/HT30yQMA0GCSqGSIb3DQEBBQUABIIBAAXEJn/z3brV653cNhjRgoE3
# Mnr10wYcoNNSnybrZtqCxmb8GViV4Dbniu4PaAT3pr1n/3l0kovfME7To8ArK91w
# crFBs+M0A06um4dRm1lgC8C26Jkc1O3BUG5WN2Vmna04LpbuMCn0JV/0qsgDkuNT
# bhVCFbVLLdll1q1Bi8HjdqONfiW0nkFbJcIhH46U6UtiIk2GDeOcS1F3qsXEUvMa
# HkS1GGQzN4U0iT9B6QAr6H25dIF+ociYMafcnDhaviPU7/lNyp1Gl+1UDQPl878X
# RbM+eD1c3DJEVc3cMlCMQnk/jXmKNeoOB2Iwsl9GQ33ie0TgkD/CV8oUMZrhSSY=
# SIG # End signature block