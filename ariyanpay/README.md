


<p align="center" >  
<img src="https://ariyanpay.com/assets/images/logo.png">  
</p>  
<h1 align="center">Ariyanpay Payment Gateway Flutter Package By Ariyan Shipu</h1>  
<p align="center" >  
</p>  


[![Pub](https://img.shields.io/pub/v/flutter_bkash.svg)](https://pub.dev/packages/ariyanpay)  
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)  
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]() [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)]()  
[![Open Source Love svg1](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)]()


<p align="center" >  
<img src="https://yt3.googleusercontent.com/Cdmgizpu7QU94Rc9uWbUUO9IXt9F8FZ1Dx_vAslp7quJEdy13I1DMcKQBDnumDrTk4KTHNci8Gg=w1060-fcrop64=1,00005a57ffffa5a8-k-c0xffffffff-no-nd-rj">  
</p>  


This is a [Flutter package](https://pub.dev/packages/ariyanpay) for [ariyanpay](https://ariyanpay.com) Payment Gateway. This package can be used in flutter project. Ariyan Shipu was created this package while working for a project and thought to release for all so that it helps.

> :warning: Please note that, you have to contact with ariyanpay sales team for any kind of dev or production access keys. We don't provide any test account or access keys or don't contact us for such.

Check the package in <a target="_blank" href="https://github.com/programmingwormhole/ariyanpay" rel="noopener">github</a> and also available in <a href="https://pub.dartlang.org/packages/ariyanpay" rel="noopener nofollow" target="_blank">flutter/dart package</a>

[![Github](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/programmingwormhole)  [![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://facebook.com/no.name.virus) [![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/no.name.virus) [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mdshirajulislam-dev) [![YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@programmingwormhole)

## How to use:
Depend on it, Run this command With Flutter:
```  
$ flutter pub add ariyanpay  
```  
This will add a line like this to your package's `pubspec.yaml` (and run an implicit **`flutter pub get`**):
```  
dependencies:  
ariyanpay: ^0.0.3
```  
Alternatively, your editor might support flutter pub get. Check the docs for your editor to learn more. Import it, Now in your Dart code, you can use:
```  
import 'package:ariyanpay/ariyanpay.dart';  
import 'package:ariyanpay/models/customer_model.dart';  
```  
## Features
- Pay using ariyanpay

## Usage
Official Link for API documentation and demo checkout
- [ariyanpay API Documentation](https://ariyanpay.readme.io/reference/overview)

### Make a Payment

***Sandbox***
```  
Ariyanpay.createPayment(  
context: context,  
customer: CustomerDetails(  
fullName: 'Ariyan Shipu',  
),  
amount: '50', 
 valueA: '',
valueB: '',
valueC: '',
valueD: '',
valueE: '',
valueF: '',
valueG: '',

);  
```  
***Production***
```  
Ariyanpay.createPayment(  
context: context,  
customer: CustomerDetails(  
fullName: 'Ariyan Shipu',  
),  
amount: '50',   
)  
```  
> Make sure to replace the provided credentials with your own ariyanpay production credentials.

***Response***
```  
final response = await ariyanpay.createPayment(  
....  
....  
)  
```  

***Response Sample***
```  
RequestResponse(  
fullName: "Ariyan Shipu",  
email: "ariyanshipuofficial@gmail.com",  
amount: "50.00","fee":"0.00",  
chargedAmount: "50.00",  
invoiceId: "a19Aun0gPxIqBVjnCfpL",  
paymentMethod: "bkash",  
senderNumber: "675675656765",  
transactionId: "FGHGFHJGHG",  
date: "2024-04-09 12:01:28",  
status: ResponseStatus.completed,  
);  
```  
### Error Handling
The methods mentioned above may throw a `status`. You can catch and handle the status using a if-else block:
```  
if (response.success == "true") {  
// handle on complete  
}  
  
if (response.status == ResponseStatus.canceled) {  
// handle on cancel  
}  
  
if (response.status == ResponseStatus.pending) {  
// handle on pending  
}  
```  

Examples for see the `/example` folder.

y


### Importance Notes
- Read the comments in the example of code
- See the documents [ariyanpay API Documentation](https://ariyanpay.readme.io/reference/overview)


## Contributing
**Core Maintainer**
- [Md Shirajul Islam](https://github.com/programmingwormhole)

Contributions to the **ariyanpay** package are welcome. Please note the following guidelines before submitting your pull request.

- Follow [Effective Dart: Style](https://dart.dev/guides/language/effective-dart/style) coding standards.
- Read ariyanpay API documentations first.Please contact with ariyanpay for their api documentation and sandbox access.

## License

ariyanpay package is licensed under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause).

Copyright 2024 [Ariyan Shipu](https://programmingwormhole.com). We are not affiliated with ariyanpay and don't give any guarantee.