//+------------------------------------------------------------------+
//|                                        EATriangularPrincipal.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/es/users/byron.mena.7"
#property version   "1.00"
#property strict

string orden;
double nuevaOrdenControl;
int nivel;
double precioApertura=0,precioCierre=0;
input int TP=2;
input double Lote_inicial=0.01;
input double Lote_segunda_opcion=0.10;
input double Lote_tercera_opcion=0.25;
input int pips_inicial=-10;
input int pips_segunda_opcion=-20;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//---
   orden="buy";
   nuevaOrdenControl=false;
   nivel=0;
   Escribir();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
 if(AccountEquity()>AccountBalance()+TP){
  nivel=0;
  Escribir(); 
 }
 
 int ordenApertura=nivel;
 Comment(
 "\n Precio de apertura (orden ",ordenApertura-1,"):",precioApertura,
 "\n Precio Actual: ",precioCierre,
 "\n Pips diferencia: ",DoubleToStr(contarDiferencia(),5),
 "\n Prueba: ",pips_inicial+pips_segunda_opcion
 );

 switch(nivel){
  case 0:
   CerrarTodasLasOperaciones();
   if(OrdersTotal()==0){
    nivel++;
    nuevaOrdenControl=false;
   }
   Escribir();
   break;
  case 1:
   NuevaOrden(Lote_inicial ,orden);
   if(OrdersTotal()==1){
    nuevaOrdenControl=true;
    nivel++;
   }
   Escribir();
  case 2:
   if(contarDiferencia()<pips_inicial){
    NuevaOrden(Lote_segunda_opcion,orden);
    nivel++;
    Escribir();
   }
   break;
  case 3:
   if(contarDiferencia()<pips_segunda_opcion){
    NuevaOrden(Lote_tercera_opcion,orden);
    nivel++;
    Escribir();
   }
   break;
 }
}
//+------------------------------------------------------------------+
//Contar los pips
double contarDiferencia(){
 double pips=0;
 for(int pos=0; pos<OrdersTotal(); pos++)
 {
  if(OrderSelect(pos, SELECT_BY_POS)==true)
  {
   if(OrderSymbol()==Symbol()){
    if(OrderType() == OP_BUY)
     pips = (OrderClosePrice()-OrderOpenPrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT));
    else if(OrderType() == OP_SELL)
     pips = (OrderOpenPrice()-OrderClosePrice())/(10*MarketInfo(OrderSymbol(),MODE_POINT));
    precioApertura=OrderOpenPrice();
    precioCierre=OrderClosePrice();
   }
  }
  else
  Print("La orden seleccionada tiene el error ",GetLastError());
 }
 return pips;
}

//Cerrar operaciones
bool CerrarTodasLasOperaciones(){
 int total = OrdersTotal();
 bool result=false;
 for(int i=total-1;i>=0;i--)
 {
  int selectOrder = OrderSelect(i, SELECT_BY_POS);
  int type   = OrderType();
  result = false;
  
  switch(type)
  {
   //Cerrar posiciones largas
   case OP_BUY : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                 break;
      
   //Cerrar posiciones cortas
   case OP_SELL : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                  break;
  }
  
  if(result == false)
  {
   Print("Orden " , OrderTicket() , " error al cerrar. Error:" , GetLastError() );
  }  
 }
 return result;
}

//Llenar archivo de control
bool Escribir(){
 bool resultado=false;
 string InpFileName = "control.txt";
 int file_handle=FileOpen("//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV,';');
 if(file_handle!=INVALID_HANDLE)
 {
  uint verifica = FileWrite(file_handle,nivel,orden,nuevaOrdenControl);
  if(verifica==0)
   PrintFormat("Error al llenar el archivo %s ",GetLastError());
  if(verifica!=0)
   resultado=true;
  FileClose(file_handle);
 }
 else{
  PrintFormat("Error al abrir %s, Código de error = %d",InpFileName,GetLastError());
 }
 return resultado;
}

//Generar una nueva orden
bool NuevaOrden(double volumen,string ordenAnterior){
 bool resultado=false;
 if(ordenAnterior=="buy"){
  resultado=OrderSend(Symbol(),OP_SELL,volumen,MarketInfo(Symbol(),MODE_BID),3,MarketInfo(Symbol(),MODE_BID)+10000*_Point,0,NULL,0,0,Green);
  orden="sell";
 }
 if(ordenAnterior=="sell"){
  resultado=OrderSend(Symbol(),OP_BUY,volumen,MarketInfo(Symbol(),MODE_ASK),3,0,MarketInfo(Symbol(),MODE_ASK)+10000*_Point,NULL,0,0,Green);
  orden="buy";
 }
 if(!resultado)
  PrintFormat("Error al abrir orden %s",GetLastError());
 return resultado;
}