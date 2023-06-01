<?xml version="1.0" encoding="UTF-8"?>

<!--                    LONG NAME: Engine Part List                  -->
<!ELEMENT  epartl %epartl.content;>
<!ATTLIST  epartl %epartl.attributes;>

<!--                    LONG NAME: Engine Part List Entry            -->
<!ELEMENT  epentry %epentry.content;>
<!ATTLIST  epentry %epentry.attributes;>


<!--                    LONG NAME: Engine Part Term                  -->
<!ELEMENT  epname %epname.content;>
<!ATTLIST  epname %epname.attributes;>


<!--                    LONG NAME: Engine Part Description           -->
<!ELEMENT  epdesc %epdesc.content;>
<!ATTLIST  epdesc %epdesc.attributes;>


<!ATTLIST  epartl    %global-atts;  class CDATA "+ topic/dl engn-d/epartl ">
<!ATTLIST  epdesc    %global-atts;  class CDATA "+ topic/dd engn-d/epdesc " >
<!ATTLIST  epentry   %global-atts;  class CDATA "+ topic/dlentry engn-d/epentry ">
<!ATTLIST  epname    %global-atts;  class CDATA "+ topic/dt engn-d/epname " >
