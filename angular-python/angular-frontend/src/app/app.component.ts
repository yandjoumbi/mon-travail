import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'Wando Web Page for hair products';

  message: string = '';
  date: string = '';
  products: string[] = []

  constructor(private http: HttpClient) {
    this.getGreeting();
    this.getTodayDate();
    this.getHairProducts();
  }

//for production
//   getGreeting(){
//     this.http.get<any>('http://flask-backend-service:5000').subscribe( response => {
//       this.message = response.message
//     });
//   }
//
// }

//for development
getGreeting(){
    this.http.get<any>('http://10.0.117.237:5000/').subscribe( response => {
      this.message = response.message
    });
  }

getTodayDate(){
    this.http.get<any>('http://10.0.117.237:5000/date').subscribe(response => {
      this.date = response.date
    });
  }

getHairProducts(){
  this.http.get<any>('http://10.0.117.237:5000/products').subscribe(response => {
        this.products = response;
        console.log(this.products)
      });
  }


}




